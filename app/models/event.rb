class Event < ActiveRecord::Base
  include SharedMethods

  ATTRIBUTES_PARAMS = [:title, :description, :status, :color, :all_day,
    :repeat_type, :repeat_every, :user_id, :calendar_id, :start_date,
    :finish_date, :start_repeat, :end_repeat, user_ids: []]

  has_many :attendees, dependent: :destroy
  has_many :users, through: :attendees
  has_many :repeat_ons
  has_many :event_exceptions, class_name: Event.name, foreign_key: :parent_id,
    dependent: :destroy

  belongs_to :calendar
  belongs_to :owner, class_name: User.name, foreign_key: :user_id
  belongs_to :event_parent, class_name: Event.name, foreign_key: :parent_id

  validates :start_date, presence: true
  validates :finish_date, presence: true
  validates :title, presence: true

  delegate :name, to: :owner, prefix: :owner, allow_nil: true
  delegate :name , to: :calendar, prefix: true, allow_nil: true

  enum exception_type: [:delete_only, :delete_all_follow, :edit_only,
    :edit_all_follow]

  enum repeat_type: [:daily, :weekly, :monthly, :yearly]

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

  scope :no_repeats, ->{where repeat_type: nil}
  scope :has_exceptions, ->{where.not exception_type: nil}
  scope :exception_edits, ->id do
    where "id = ? AND exception_type IN (?)", id, [2, 3]
  end

  def json_data user_id
    {
      id: SecureRandom.urlsafe_base64,
      title: title,
      start_date: format_datetime(start_date),
      finish_date: format_datetime(finish_date),
      start_repeat: format_date(start_date),
      end_repeat: format_date(end_repeat),
      color_id: calendar.get_color(user_id),
      calendar: calendar.name,
      all_day: all_day,
      repeat_type: repeat_type,
      repeat: load_repeat_data,
      exception_type: exception_type,
      parent_id: parent_id,
      exception_time: exception_time,
      event_id: id
    }
  end

  def is_diff_between_start_and_finish_date?
    start_date.to_date != finish_date.to_date
  end

  private
  def format_time datetime
    datetime.try :strftime, Settings.event.format_time
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
