class Notification < ActiveRecord::Base
  has_many :notification_events, dependent: :destroy
end
