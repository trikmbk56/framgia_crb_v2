class SyncGoogleCalendarServices

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
    events = results.data.items.select do |event|
      event.status == Settings.status_confirmed
    end
    events.each{|event| create_event event}
  end

  def push_event
    insert_event_to_calendar
  end

  private
  def extract_event_title title
    calendar_name, event_title = title.split(": ").each{|string| string.capitalize!}
    calendar = @calendars.find_by name: calendar_name
    calendar_id = calendar.present? ? calendar.id : @default_calendar.id

    return calendar_id, event_title
  end

  def create_event event_sync
    calendar_id, event_title = extract_event_title event_sync.summary
    event = Event.new
    event.title = event_title
    event.description = event_sync.description
    event.user_id = @current_user.id
    event.calendar_id = calendar_id
    if event_sync.recurring_event_id.present?
      event.google_event_id = event_sync.recurringEventId
    else
      event.google_event_id = event_sync.id
    end
    set_date_time_for_event event_sync, event
    handle_repeat event_sync, event
    event.save
  end

  def set_date_time_for_event event_sync, event
    if event_sync.start.date.present?
      event.all_day = true
      event.start_date = event.start_repeat =
        event_sync.start.date.to_datetime.beginning_of_day
        .strftime Settings.event.format_datetime
      event.finish_date = event_sync.end.date.to_datetime
        .end_of_day.strftime Settings.event.format_datetime
      if event_sync.recurring_event_id.present?
        event.delete_only!
        event.exception_time = event.start_date
      end
    else
      event.start_date = event.start_repeat =
        event_sync.start.dateTime.strftime Settings.event.format_datetime
      event.finish_date =
        event_sync.end.dateTime.strftime Settings.event.format_datetime
      if event_sync.recurring_event_id.present?
        event.delete_only!
        event.exception_time = event.start_date
      end
    end
  end

  def handle_repeat event_sync, event
    if event_sync.recurrence.present?
      repeat_type, end_repeat, every, repeat_ons =
        extract_info_repeat event_sync.recurrence[0]
      if event_sync.start.date.present?
        event.start_repeat = event_sync.start.date
      else
        event.start_repeat = event_sync.start.dateTime
          .strftime Settings.event.format_datetime
      end
      event.end_repeat = end_repeat.beginning_of_day
        .strftime Settings.event.format_datetime
      event.repeat_type = Event::repeat_types[repeat_type]
      event.repeat_every = every ||= 1 unless repeat_type.nil?
    else
      if event_sync.end.date.present?
        event.end_repeat = event_sync.end.date
      else
        event.end_repeat = event_sync.end.dateTime.beginning_of_day
          .strftime Settings.event.format_datetime
        end
      end
    end
  end

  def insert_event_to_calendar
    events = @user.events
    client = Google::APIClient.new
    client.authorization.access_token = @token
    service = client.discovered_api("calendar", "v3")
    events.each do |event|
      if event.google_event_id.nil?
        attendees = event.attendees
        emails = Array.new
        attendees.each {|attendee| emails << {email: attendee.user_email}}
        recurrences = event.repeat_type.nil? ? "" : recurrence_google_calendar(event)
        event_google = event_google_calendar event, client, service, recurrences, emails
        result = client.execute(api_method: service.events.insert,
          parameters: {"calendarId": "primary"},
          body: JSON.dump(event_google),
          headers: {"Content-Type": Settings.content_type})
        event.google_event_id = result.data.id
        event.save
      end
    end
  end

  def extract_info_repeat recurrence_string
    recurrence_string.slice! "RRULE:"
    recurrence_hash =
      Hash[recurrence_string.split(";").collect{|string| string.strip.split("=")}]
    repeat_type = recurrence_hash["FREQ"].downcase
    end_repeat = recurrence_hash["UNTIL"].to_datetime
    every = recurrence_hash["INTERVAL"]
    repeat_ons = recurrence_hash["BYDAY"].split(",") unless recurrence_hash["BYDAY"].nil?

    return repeat_type, end_repeat, every, repeat_ons
  end

  def google_calendar_time_zone client, service
    response = client.execute(api_method: service.calendar_list.list)
    calendar = response.data.items.first
    calendar.timeZone
  end

  def google_calendar_time_format client, service, dateTime
    time_zone = google_calendar_time_zone client, service
    time = dateTime.to_datetime.rfc3339.split("+")[0]
    zone = dateTime.in_time_zone(time_zone).to_datetime.rfc3339
    timeZone = /\+([^\]]+)/.match(zone)
    time + timeZone.to_s
  end

  def join_event_title event
    event.calendar.name.capitalize + ": "+ event.title
  end

  def recurrence_google_calendar event
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

  def event_google_calendar event, client, service, recurrences, emails
    event_google = {
      "summary": join_event_title(event),
      "description": event.description,
      "start": {
        "dateTime": google_calendar_time_format(client, service, event.start_date),
        "timeZone": google_calendar_time_zone(client, service)
      },
      "end": {
        "dateTime": google_calendar_time_format(client, service, event.finish_date),
        "timeZone": google_calendar_time_zone(client, service)
      },
      "recurrence": recurrences,
      "attendees": emails
    }
  end
end
