class EventGoogle
  ATTRS = [:description, :google_event_id]

  attr_reader *ATTRS

  def initialize event_sync, parent = nil, calendars, default_calendar, current_user
    @event_sync = event_sync
    @parent = parent
    @calendars = calendars
    @default_calendar = default_calendar
    @current_user = current_user
    @description = @event_sync.description
    @google_event_id = @event_sync.id
  end

  def convert_to_local
    event = Event.new
    calendar_id, event_title = extract_event_title @event_sync.summary
    event.title = event_title
    event.description = description
    event.user_id = @current_user.id
    event.calendar_id = calendar_id
    event.google_event_id = google_event_id
    set_date_time_for_event @event_sync, event
    repeat_ons = handle_repeat @event_sync, event, @parent
    event.parent_id = @parent.id if @event_sync.id.include?("_")
    return event, repeat_ons
  end

  def is_child_event?
    @event_sync.id.include?("_") && @event_sync.id.split("_").first == @parent.google_event_id
  end

  private
  def extract_event_title title
    calendar_name, event_title = title.split(": ").each{|string| string.capitalize!}
    calendar = @calendars.find_by name: calendar_name
    calendar_id = calendar.present? ? calendar.id : @default_calendar.id

    return calendar_id, event_title
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
        event.exception_type = Event.exception_types[:edit_only]
        event.exception_time = event.start_date
      elsif event_sync.recurring_event_id.blank? && event_sync.id.include?("_R")
        event.exception_type = Event.exception_types[:edit_all_follow]
        event.exception_time = event.start_date
      end
    else
      event.start_date = event.start_repeat =
        event_sync.start.dateTime.strftime Settings.event.format_datetime
      event.finish_date =
        event_sync.end.dateTime.strftime Settings.event.format_datetime
      if event_sync.recurring_event_id.present?
        event.exception_type = Event.exception_types[:edit_only]
        event.exception_time = event.start_date
      elsif event_sync.recurring_event_id.blank? && event_sync.id.include?("_R")
        event.exception_type = Event.exception_types[:edit_all_follow]
        event.exception_time = event.start_date
      end
    end
  end

  def handle_repeat event_sync, event, parent
    if event_sync.recurrence.present?
      repeat_type, end_repeat, every, repeat_ons =
        extract_info_repeat event_sync.recurrence[0], event
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
      event.repeat_type = parent.repeat_type
      event.repeat_every = parent.repeat_every
    end
    repeat_ons
  end

  def extract_info_repeat recurrence_string, event
    recurrence_string.slice! "RRULE:"
    recurrence_hash =
      Hash[recurrence_string.split(";").collect{|string| string.strip.split("=")}]
    repeat_type = recurrence_hash["FREQ"].downcase
    if recurrence_hash["UNTIL"].present?
      end_repeat = recurrence_hash["UNTIL"].to_datetime
    else
      end_repeat = event.start_date + 1.years
    end
    every = recurrence_hash["INTERVAL"]
    repeat_ons = recurrence_hash["BYDAY"].split(",") unless recurrence_hash["BYDAY"].nil?

    return repeat_type, end_repeat, every, repeat_ons
  end
end
