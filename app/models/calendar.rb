class Calendar < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :user_calendars, dependent: :destroy
  has_many :users, through: :user_calendars
  has_many :sub_calendars, class_name: Calendar.name, foreign_key: :parent_id

  belongs_to :color
  belongs_to :owner, class_name: User.name

  ATTRIBUTES_PARAMS = [:name, :description, :user_id, :color_id, :parent_id]
end
