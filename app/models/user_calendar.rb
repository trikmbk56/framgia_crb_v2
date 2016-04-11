class UserCalendar < ActiveRecord::Base
  belongs_to :user
  belongs_to :calendar
  belongs_to :permission
end
