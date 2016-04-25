class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable, :validatable,
    :registerable

  has_attached_file :avatar, styles: { small: "150x150>" },
    default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  has_many :user_calendars, dependent: :destroy
  has_many :calendars, dependent: :destroy
  has_many :shared_calendars, through: :user_calendars, source: :calendar
  has_many :attendees, dependent: :destroy
  has_many :events
  has_many :invited_events, through: :attendees, source: :event
end
