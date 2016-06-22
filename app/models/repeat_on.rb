class RepeatOn < ActiveRecord::Base
  belongs_to :event
  belongs_to :days_of_week
end
