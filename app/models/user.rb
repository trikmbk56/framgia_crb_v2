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

  QUERRY_MY_CALENDAR = "id in (select calendars.id from
    calendars join user_calendars on user_calendars.calendar_id = calendars.id
    where permission_id <> 5 and calendars.user_id = ?)"

  QUERRY_OTHER_CALENDAR = "id in (select calendars.id from
    calendars join user_calendars on user_calendars.calendar_id = calendars.id
    where user_calendars.user_id = ? and (user_calendars.permission_id IN (?) 
    and calendars.user_id <> ? OR (permission_id = 5 AND calendar_id IN (?))))"

  def my_calendars
    calendars.where QUERRY_MY_CALENDAR, id
  end

  def other_calendars
    publics = Calendar.calendars_public user_calendars.pluck :calendar_id
    Calendar.where QUERRY_OTHER_CALENDAR, id, [1, 2, 3, 4], id, publics.ids
  end 

  private
  def create_calendar
    self.calendars.create({name: self.name, color_id: 1, is_default: true})
  end
end
