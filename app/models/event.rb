class Event < ActiveRecord::Base
  has_many :attendees, dependent: :destroy
  has_many :users, through: :attendees

  belongs_to :calendar
  belongs_to :owner, class_name: User.name
end
