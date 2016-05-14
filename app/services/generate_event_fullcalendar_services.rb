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
      @repeat_every = event.repeat_every
      case event.repeat_type
      when "daily"
        repeat_daily event
      when "weekly"
        @start_day = @event_temp.start_date.wday
        @repeat_ons = event.repeat_ons
        @repeat_ons.each do |repeat|
          set_calculate_day repeat
          if @calculate_day == @start_day
            repeat_weekly event
          elsif @calculate_day > @start_day
            @event_temp.start_date = event.start_date + (@calculate_day -
              @start_day).days
            @event_temp.finish_date = event.finish_date + (@calculate_day -
              @start_day).days
            @event_shows << @event_temp.dup
            repeat_weekly event
          else
            @event_temp.start_date = event.start_date + (7 + @calculate_day -
              @start_day).days
            @event_temp.finish_date = event.finish_date + (7 + @calculate_day -
              @start_day).days
            @event_shows << @event_temp.dup
            repeat_weekly event
          end
        end
      when "monthly"
        repeat_monthly event
      when "yearly"
        repeat_yearly event
      end
    end
    @event_shows.map{|event| event.json_data(@current_user.id)}
  end

  private
  def new_event_fullcalendar event
    @event_temp = EventFullcalendar.new event
    @event_shows << @event_temp.dup
  end

  def repeat_daily event
    while @event_temp.start_date < event.end_repeat - 1.days
      @event_temp.start_date += @repeat_every.days
      @event_temp.finish_date += @repeat_every.days
      @event_shows << @event_temp.dup
    end
  end

  def repeat_weekly event
    while @event_temp.start_date < event.end_repeat - 1.weeks
      @event_temp.start_date += @repeat_every.weeks
      @event_temp.finish_date += @repeat_every.weeks
      @event_shows << @event_temp.dup
    end
  end

  def repeat_monthly event
    while @event_temp.start_date < event.end_repeat - 1.months
      @event_temp.start_date += @repeat_every.months
      @event_temp.finish_date += @repeat_every.months
      @event_shows << @event_temp.dup
    end
  end

  def repeat_yearly event
    while @event_temp.start_date < event.end_repeat - 1.years
      @event_temp.start_date += @repeat_every.years
      @event_temp.finish_date += @repeat_every.years
      @event_shows << @event_temp.dup
    end
  end

  def set_calculate_day repeat
    @repeat_on = repeat.repeat_on
    @calculate_day = RepeatOn::repeat_ons[@repeat_on]
  end
end
