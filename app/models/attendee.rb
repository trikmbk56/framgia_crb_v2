class Attendee < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  delegate :name, to: :user, prefix: :user, allow_nil: :true
end
