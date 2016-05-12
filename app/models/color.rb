class Color < ActiveRecord::Base
  has_many :calendars
  has_many :user_calendars
end
