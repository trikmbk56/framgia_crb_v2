module EventsHelper
  def select_my_calendar calendars
    calendars.collect do |calendar| 
      [calendar.name, calendar.id]
    end
  end
end
