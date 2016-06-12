class EventFullcalendar
  include SharedMethods

  ATTRS = [:id, :title, :description, :status, :color, :all_day,
    :repeat_type, :repeat_every, :user_id, :calendar_id, :start_date, :finish_date,
    :start_repeat, :end_repeat, :exception_time, :exception_type, :event_id]

  attr_accessor *ATTRS

  def initialize event
    ATTRS[1..-2].each do |attr|
      instance_variable_set "@#{attr}", event.send(attr)
    end
    @id, @event_id = SecureRandom.urlsafe_base64, event.id
  end

  def json_data user_id
    {
      id: id,
      title: title,
      start_date: format_datetime(start_date),
      finish_date: format_datetime(finish_date),
      start_repeat: format_date(start_date),
      end_repeat: format_date(end_repeat),
      color_id: load_calendar(calendar_id).get_color(user_id),
      calendar: load_calendar(calendar_id).name,
      all_day: all_day,
      repeat_type: repeat_type,
      exception_type: exception_type,
      event_id: event_id,
      exception_time: exception_time,
      editable: valid_permission_user_in_calendar?(user_id, calendar_id)
    }
  end

  def valid_permission_user_in_calendar? user_id, calendar_id
    user_calendar = UserCalendar.find_by(user_id: user_id, calendar_id: calendar_id)
    Settings.permissions_can_make_change.include? user_calendar.permission_id
  end

  def load_calendar calendar_id
    @calendar = Calendar.find_by id: calendar_id
  end
end
