class Calendar < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :user_calendars, dependent: :destroy
  has_many :users, through: :user_calendars

  belongs_to :color
  belongs_to :owner, class_name: User.name

  ATTRIBUTES_PARAMS = [:name, :description, :user_id, :color_id]
end
