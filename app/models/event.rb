class Event < ActiveRecord::Base

  ATTRIBUTES_PARAMS = [:title, :description, :status, :color, :user_id,
    :calendar_id, :start_date, :finish_date, user_ids: []]

  has_many :attendees, dependent: :destroy
  has_many :users, through: :attendees

  belongs_to :calendar
  belongs_to :owner, class_name: User.name, foreign_key: :user_id

  validates :start_date, presence: true
  validates :finish_date, presence: true
  validates :title, presence: true

  delegate :name, to: :owner, prefix: :owner, allow_nil: true

  scope :my_events, ->user_id do
    where("finish_time between ? and ? and user_id = ?",
      Date.today.beginning_of_week, Date.today.end_of_week, user_id)
  end

  scope :upcoming_event, ->calendar_id {
    where("start_date >= ? AND calendar_id IN (?)", DateTime.now, calendar_id).
      order start_date: :asc
  }

  def json_data
    {
      id: id,
      title: title,
      start_date: format_datetime(start_date),
      finish_date: format_datetime(finish_date)
    }
  end

  private
  def format_datetime datetime
    datetime.try :strftime, "%Y-%m-%d %H:%M"
  end
end
