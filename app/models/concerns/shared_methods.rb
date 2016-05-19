module SharedMethods
  extend ActiveSupport::Concern

  def format_date datetime
    datetime.try :strftime, Settings.event.format_date
  end

  def format_datetime datetime
    datetime.try :strftime, Settings.event.format_datetime
  end
end
