class EventForm < Reform::Form
  ATTRS = [:id, :title, :description, :status, :color, :all_day,
    :repeat_type, :repeat_every, :user_id, :calendar_id, :start_date, :finish_date,
    :start_repeat, :end_repeat, :exception_time, :exception_type]

  ATTRS.each{|attribute| property attribute}

  collection :attendees, populate_if_empty: Attendee do
    property :email
  end

  collection :notification_events, populate_if_empty: NotificationEvent do
    property :notification_id
    property :event_id
  end

  collection :repeat_ons, populate_if_empty: RepeatOn do
    property :repeat_on
  end

  validates :title, presence: true
end
