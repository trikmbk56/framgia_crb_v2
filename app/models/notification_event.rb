class NotificationEvent < ActiveRecord::Base
  belongs_to :event
  belongs_to :notification
end
