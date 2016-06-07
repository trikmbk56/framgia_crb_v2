class RepeatOn < ActiveRecord::Base
  belongs_to :event

  enum repeat_on: [:su, :mo, :tu, :we, :th, :fr, :sa]
end
