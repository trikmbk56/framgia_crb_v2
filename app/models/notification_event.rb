class NotificationEvent < ActiveRecord::Base
  belongs_to :event
  belongs_to :notification

  ATTRIBUTES_PARAMS = [:event_id, :notification_id]

  delegate :notification_type, to: :notification, allow_nil: :true
end
