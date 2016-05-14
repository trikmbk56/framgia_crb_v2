class RepeatOn < ActiveRecord::Base
  belongs_to :event

  enum repeat_on: [:sun, :mon, :tue, :wed, :thu, :fri, :sat]
end
