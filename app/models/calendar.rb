class Calendar < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :user_calendars, dependent: :destroy
  has_many :users, through: :user_calendars
  has_many :sub_calendars, class_name: Calendar.name, foreign_key: :parent_id

  accepts_nested_attributes_for :user_calendars, allow_destroy: true
  belongs_to :color
  belongs_to :owner, class_name: User.name

  ATTRIBUTES_PARAMS = [:name, :description, :user_id, :color_id, :parent_id, :status,
    user_calendars_attributes: [:id, :user_id, :permission_id, :_destroy]]

  after_create :create_user_calendar

  enum status: [:no_public, :share_public, :public_hide_detail]

  scope :calendars_public, ->calendars_id do
    where(id: calendars_id).where.not status: Calendar.statuses[:no_public]
  end

  def get_color user_id
    user_calendar = user_calendars.find_by user_id: user_id
    color_id = user_calendar.color_id
  end

  def parent?
    parent_id.nil?
  end

  private
  def create_user_calendar
    self.user_calendars.create({user_id: self.user_id, permission_id: 1,
      color_id: self.color_id})
  end
end
