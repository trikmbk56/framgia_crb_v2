class Event < ActiveRecord::Base
  ATTRIBUTES_PARAMS = [:title, :description, :status, :color, :user_id,
    :calendar_id, :start_time, :finish_time]

  has_many :attendees, dependent: :destroy
  has_many :users, through: :attendees

  belongs_to :calendar
  belongs_to :owner, class_name: User.name, foreign_key: :user_id

  delegate :name, to: :owner, prefix: :owner, allow_nil: true

  scope :my_events, ->user_id do
    where("finish_time between ? and ? and user_id = ?",
      Date.today.beginning_of_week, Date.today.end_of_week, user_id)
  end

  def json_data
    {
      id: id,
      title: title,
      start_time: format_datetime(start_time),
      end_time: format_datetime(finish_time)
    }
  end

  private
  def format_datetime datetime
    datetime.try :strftime, "%Y-%m-%d %H:%M"
  end
end
