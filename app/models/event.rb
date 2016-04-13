class Event < ActiveRecord::Base
  has_many :attendees, dependent: :destroy
  has_many :users, through: :attendees

  belongs_to :calendar
  belongs_to :owner, class_name: User.name

  ATTRIBUTES_PARAMS = [:title, :description, :status, :color, :user_id,
    :calendar_id, :start_time, :finish_time]
  belongs_to :owner, class_name: User.name, foreign_key: :user_id

  delegate :name, to: :owner, prefix: :owner, allow_nil: true
end
