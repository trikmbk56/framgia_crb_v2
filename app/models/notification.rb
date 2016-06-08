class Notification < ActiveRecord::Base
  has_many :notification_events, dependent: :destroy
  has_many :events, through: :notification_events
end
