class GenerateEventFullcalendarServices
  def initialize events, current_user
    @events = events
    @current_user = current_user
  end

  def repeat_data
    @event_shows = []
    @event_no_repeats = @events.no_repeats
    if @event_no_repeats.size > 0
      @event_no_repeats.each do |event|
        new_event_fullcalendar event
      end
    end
    @event_has_repeats = @events - @event_no_repeats
    @event_has_repeats.each do |event|
      new_event_fullcalendar event
      case event.repeat_type
      when "daily"
        while @event_temp.start_date < event.end_repeat - 1.days
          @event_temp.start_date += 1.days
          @event_temp.finish_date += 1.days
          @event_shows << @event_temp.dup
        end
      when "monthly"
        while @event_temp.start_date < event.end_repeat - 1.months
          @event_temp.start_date += 1.months
          @event_temp.finish_date += 1.months
          @event_shows << @event_temp.dup
        end
      when "yearly"
        while @event_temp.start_date < event.end_repeat - 1.years
          @event_temp.start_date += 1.years
          @event_temp.finish_date += 1.years
          @event_shows << @event_temp.dup
        end
      end
    end
    @event_shows.map{|event| event.json_data(@current_user.id)}
  end

  def new_event_fullcalendar event
    @event_temp = EventFullcalendar.new event
    @event_shows << @event_temp
  end
end
