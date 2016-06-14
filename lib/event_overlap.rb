class EventOverlap
  ATTRS = [:time_overlap]
  attr_accessor *ATTRS

  def initialize event = nil
    @time_overlap = nil
    array_time_from_fullcalendar event.calendar
    array_time_from_event event
  end

  def overlap?
    @array_time_fullcalendar.each do |time_fullcalendar|
      @array_time_event.each do |time_event|
        if compare_time? time_fullcalendar, time_event
          @time_overlap = time_event[:start_date]
          return true
        end
      end
    end
    false
  end

  private
  def array_time_from_fullcalendar calendar
    events = calendar.events
    event_exceptions = events.has_exceptions
    @array_time_fullcalendar = FullcalendarService.new(events,
      event_exceptions).repeat_data.select do |event|
      event.exception_type.nil? || event.exception_type > 1
    end
    @array_time_fullcalendar = @array_time_fullcalendar.collect do |event|
      {start_date: event.start_date, finish_date: event.finish_date}
    end
    @array_time_fullcalendar = @array_time_fullcalendar.sort_by do |event|
      event[:start_date]
    end
  end

  def array_time_from_event event
    @array_time_event =
      FullcalendarService.new([event]).generate_event.collect do |event|
      {start_date: event.start_date, finish_date: event.finish_date}
    end
  end

  def compare_time? time1, time2
    (time1[:start_date].to_datetime - time2[:finish_date].to_datetime) * 
      (time1[:finish_date].to_datetime - time2[:start_date].to_datetime) < 0
  end
end
