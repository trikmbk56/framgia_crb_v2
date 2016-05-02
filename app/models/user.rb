class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable, :validatable,
    :registerable

  has_many :user_calendars, dependent: :destroy
  has_many :calendars, dependent: :destroy
  has_many :shared_calendars, through: :user_calendars, source: :calendar
  has_many :attendees, dependent: :destroy
  has_many :events
  has_many :invited_events, through: :attendees, source: :event

  after_create :create_calendar

  private
  def create_calendar
    self.calendars.create({name: self.name, color_id: 1})
  end
end
