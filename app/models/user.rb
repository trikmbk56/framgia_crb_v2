class User < ActiveRecord::Base
  has_many :user_calendars, dependent: :destroy
  has_many :calendars, dependent: :destroy
  has_many :shared_calendars, through: :user_calendars, source: :calendar
  has_many :attendees, dependent: :destroy
  has_many :events
  has_many :invited_events, through: :attendees, source: :event
end
