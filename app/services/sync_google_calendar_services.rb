class SyncGoogleCalendarServices
  def initialize events
    @events = events
  end

  private
  def extract_event_title title
    calendar_name, event_title = title.split(": ")
  end
end
