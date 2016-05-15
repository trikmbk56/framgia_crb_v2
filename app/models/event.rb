class Event < ActiveRecord::Base

  ATTRIBUTES_PARAMS = [:title, :description, :status, :color, :all_day, :user_id,
    :calendar_id, :start_date, :finish_date, :start_repeat, :end_repeat, user_ids: []]

  has_many :attendees, dependent: :destroy
  has_many :users, through: :attendees
  has_many :repeat_ons

  belongs_to :calendar
  belongs_to :owner, class_name: User.name, foreign_key: :user_id

  validates :start_date, presence: true
  validates :finish_date, presence: true
  validates :title, presence: true

  delegate :name, to: :owner, prefix: :owner, allow_nil: true
  delegate :name , to: :calendar, prefix: true, allow_nil: true

  scope :my_events, ->user_id do
    where("finish_time between ? and ? and user_id = ?",
      Date.today.beginning_of_week, Date.today.end_of_week, user_id)
  end

  scope :in_calendars, ->calendars do
    where "calendar_id IN (?)", calendars
  end

  scope :upcoming_event, ->calendar_id do
    where("start_date >= ? AND calendar_id IN (?)", DateTime.now, calendar_id).
      order start_date: :asc
  end

  def json_data user_id
    {
      id: id,
      title: title,
      start_date: format_time(start_date),
      finish_date: format_time(finish_date),
      start_repeat: format_date(start_date),
      end_repeat: format_date(end_repeat),
      color_id: calendar.get_color(user_id),
      calendar: calendar.name,
      all_day: all_day,
      repeat_type: repeat_type,
      repeat: load_repeat_data
    }
  end

  def is_diff_between_start_and_finish_date?
    start_date.to_date != finish_date.to_date
  end

  private
  def format_date datetime
    datetime.try :strftime, Settings.event.format_date
  end

  def format_time datetime
    datetime.try :strftime, Settings.event.format_time
  end

  def format_datetime datetime
    datetime.try :strftime, Settings.event.format_datetime
  end

  def load_repeat_data
    if repeat_type == 1
      repeat = Settings.event.repeat_daily
    elsif repeat_type == 2
      repeat = (repeat_ons.pluck :repeat_on).compact
    else
      nil
    end 
  end
end
