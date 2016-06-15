class GoogleCalendarService

  def initialize client, service, current_user, token
    @token = token
    @client = client
    @service = service
    @current_user = current_user
    @calendars = Calendar.all
    @default_calendar = current_user.calendars.find_by is_default: true
  end

  def pull_events
    results = @client.execute(api_method: @service.events.list,
      parameters: {"calendarId": @current_user.google_calendar_id})
    events = results.data.items
    save_event events
  end

  def push_events
    insert_event
    delete_event
  end

  private
  def save_event events
    google_parent_events = Array.new
    events.each do |event|
      if event.status == Settings.status_confirmed
        event_google = EventGoogle.new(event, @calendars, @default_calendar,
          @current_user)
        unless event.id.include?("_")
          event_temp = find_event_in_database event.id
          if event_temp.present?
            google_parent_events << update_event_after_convert(event_temp.id, event_google)
          else
            google_parent_events << save_event_after_convert(event_google)
          end
        end
      end
    end
    delete_parent_event google_parent_events
    google_parent_events.each do |event_parent|
      events.each do |event|
        event_google = EventGoogle.new(event, event_parent, @calendars,
          @default_calendar, @current_user)
        if event_google.is_child_event?
          event_temp = find_event_in_database event.id
          if event_temp.present?
            update_event_after_convert event_temp.id, event_google
          else
            save_event_after_convert event_google
          end
        end
      end
    end
  end

  def delete_parent_event sync_events
    google_event_ids = Event.google_events.map{|event| event.google_event_id}
    sync_events_ids = sync_events.map{|event| event.google_event_id}
    delete_event_ids = google_event_ids - sync_events_ids
    delete_event_ids.each do |google_event_id|
      Event.find_by(google_event_id: google_event_id)
        .exception_type = Event.exception_types[:delete_only]
    end
  end

  def save_event_after_convert event_google
    event, repeat_ons = event_google.convert_to_local
    if event.save && repeat_ons.present?
      create_repeat_on event.id, repeat_ons
    end
    event
  end

  def update_event_after_convert event_id, event_google
    event, repeat_ons = event_google.convert_to_local
    hash = build_string_update event_id, event
    if Event.update(hash.keys, hash.values) && repeat_ons.present?
      RepeatOn.destroy_all id: event.id
      create_repeat_on event.id, repeat_ons
    end
    Event.find_by id: event_id
  end

  def create_repeat_on event_id, repeat_ons
    repeat_ons.each do |on|
      object_repeat_on = RepeatOn.new
      object_repeat_on.event_id = event_id
      object_repeat_on.repeat_on = RepeatOn::repeat_ons[on.downcase]
      object_repeat_on.save
    end
  end

  def find_event_in_database google_event_id
    Event.find_by google_event_id: google_event_id
  end

  def build_string_update event_id, event_update
    event_hash = Hash.new
    event_hash[event_id] =
      event_update.as_json.except!("id", "created_at", "updated_at")
    event_hash
  end

  def time_format client, service, dateTime
    time_Zone = time_zone client, service
    time = dateTime.to_datetime.rfc3339.split("+")[0]
    zone = dateTime.in_time_zone(time_Zone).to_datetime.rfc3339
    timeZone = /\+([^\]]+)/.match(zone)
    time + timeZone.to_s
  end

  def time_zone client, service
    response = client.execute(api_method: service.calendar_list.list)
    calendar = response.data.items.first
    calendar.timeZone
  end

  def join_event_title event
    event.calendar.name.capitalize + ": "+ event.title
  end

  def recurrence_event event
    recurrences = Array.new
    recurrence = "RRULE:FREQ=" + event.repeat_type.upcase + ";" +
      "UNTIL=" + event.end_repeat.strftime(Settings.event.format_date_basic) + ";" +
      "INTERVAL=" + event.repeat_every.to_s
    if event.weekly?
      repeat_on_day = "BYDAY="
      event.repeat_ons.each do |repeat|
        repeat_on_day += repeat.repeat_on.upcase + ","
      end
      recurrence = recurrence + ";" + repeat_on_day.chomp(",")
    end
    recurrences << recurrence
  end

  def email_of_attendees event
    attendees = event.attendees
    emails = Array.new
    attendees.each {|attendee| emails << {email: attendee.user_email}}
    emails
  end

  def add_event_to_google event
    emails = email_of_attendees event
    recurrences = event.repeat_type.nil? ? "" : recurrence_event(event)
    event_google = event_google_calendar event, @client, @service, recurrences, emails
    result = @client.execute(api_method: @service.events.insert,
      parameters: {"calendarId": @current_user.google_calendar_id},
      body: JSON.dump(event_google),
      headers: {"Content-Type": Settings.content_type})
    if result.status == 200
      event.google_event_id = result.data.id
      event.google_calendar_id = @current_user.google_calendar_id
      event.save
    end
  end

  def delete_event_repeat instance
    instance.status = "cancelled"
    response = @client.execute(api_method: @service.events.update,
      parameters: {"calendarId": @current_user.google_calendar_id,
      "eventId": instance.id},
      body_object: instance,
      headers: {"Content-Type": Settings.content_type})
    google_event_id_new_event = instance.id.split("T")[0]
    event = Event.find_by google_event_id: google_event_id_new_event
    unless event.nil?
      add_event_to_google event
    end
  end

  def update_event_repeat instance, event
    instance.summary = join_event_title event
    instance.description = event.description
    instance.start.dateTime = time_format @client, @service, event.start_date
    instance.start.timeZone = time_zone @client, @service
    instance.end.dateTime = time_format @client, @service, event.finish_date
    instance.end.timeZone = time_zone @client, @service
    recurrences = event.repeat_type.nil? ? "" : recurrence_event(event)
    instance.recurrence = recurrences
    instance.attendees = email_of_attendees event
    response = @client.execute(api_method: @service.events.update,
      parameters: {"calendarId": @current_user.google_calendar_id,
      "eventId": instance.id},
      body_object: instance,
      headers: {"Content-Type": Settings.content_type})
  end

  def event_google_calendar event, client, service, recurrences, emails
    event_google = {
      "summary": join_event_title(event),
      "description": event.description,
      "start": {
        "dateTime": time_format(client, service, event.start_date),
        "timeZone": time_zone(client, service)
      },
      "end": {
        "dateTime": time_format(client, service, event.finish_date),
        "timeZone": time_zone(client, service)
      },
      "recurrence": recurrences,
      "attendees": emails
    }
  end

  def update_infor_event_repeat event
    results = @client.execute(api_method: @service.events.instances,
      parameters: {"calendarId": event.event_parent.google_calendar_id,
      "eventId": event.event_parent.google_event_id})
    instances = results.data["items"]
    instances.each_with_index do |instance, index|
      instance_time = instance.originalStartTime["dateTime"].to_datetime.rfc3339
      if time_format(@client, @service, event.exception_time) == instance_time
        if event.delete_only?
          delete_event_repeat instance
        elsif event.delete_all_follow?
          (index..instances.count-1).each do |i|
            delete_event_repeat instances[i]
          end
        elsif event.edit_only?
          update_event_repeat instance, event
        elsif
          (index..instances.count-1).each do |i|
            update_event_repeat instances[i], event
          end
        end
      end
    end
  end

  def insert_event
    manage_calendars = @current_user.manage_calendars
    calendar_ids = manage_calendars.pluck(:id)
    events = Event.in_calendars calendar_ids
    events.each do |event|
      if event.google_event_id.nil?
        add_event_to_google event if event.exception_type.nil?
        if event.event_parent.present? && event.event_parent.google_event_id.present?
          update_infor_event_repeat event
        end
      elsif event.google_event_id.present?
        unless event.exception_type.nil?
          update_infor_event_repeat event
        end
      end
    end
  end

  def delete_event
    manage_calendars = @current_user.manage_calendars
    calendar_ids = manage_calendars.pluck(:id)
    event_deleteds = Event.only_deleted.deleted_event_google calendar_ids
    event_deleteds.each do |event|
      results = @client.execute(api_method: @service.events.delete,
        parameters: {"calendarId": event.google_calendar_id,
        "eventId": event.google_event_id})
    end
  end
end

