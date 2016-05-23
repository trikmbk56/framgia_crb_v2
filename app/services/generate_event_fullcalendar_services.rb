class GenerateEventFullcalendarServices
  def initialize events, current_user, event_exceptions
    @events = events
    @current_user = current_user
    @event_exceptions = event_exceptions
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
      @event_temp = EventFullcalendar.new event
      @repeat_every = event.repeat_every
      unless event.parent_id.present?
        case event.repeat_type
        when "daily"
          repeat_daily event, event.start_repeat.to_date
        when "weekly"
          @start_day = event.start_repeat.wday
          @repeat_ons = event.repeat_ons
          @repeat_ons.each do |repeat|
            @repeat = repeat
            set_calculate_day @repeat
            if @calculate_day == @start_day
              repeat_weekly event, event.start_repeat.to_date
            elsif @calculate_day > @start_day
              @start = event.start_repeat.to_date + (@calculate_day -
                @start_day).days
              repeat_weekly event, @start
            else
              @start = event.start_repeat.to_date + (Settings.seven +
                @calculate_day - @start_day).days
              repeat_weekly event, @start
            end
          end
        when "monthly"
          repeat_monthly event, event.start_repeat.to_date
        when "yearly"
          repeat_yearly event, event.start_repeat.to_date
        end
      end
    end
    @event_shows.map{|event| event.json_data(@current_user.id)}
  end

  private
  def new_event_fullcalendar event
    @event_temp = EventFullcalendar.new event
    @event_shows << @event_temp.dup
  end

  def repeat_daily event, start
    show_repeat_event event, @repeat_every.days, start
  end

  def repeat_weekly event, start
    show_repeat_event event, @repeat_every.weeks, start
  end

  def repeat_monthly event, start
    show_repeat_event event, @repeat_every.months, start
  end

  def repeat_yearly event, start
    show_repeat_event event, @repeat_every.years, start
  end

  def set_calculate_day repeat
    @repeat_on = repeat.repeat_on
    @calculate_day = RepeatOn::repeat_ons[@repeat_on]
  end

  def weekly_start_exception ex_event
    @ex_day = ex_event.exception_time.wday
    if @calculate_day == @ex_day
      @start_exception = ex_event.exception_time.to_date
    elsif @calculate_day > @ex_day
      @start_exception = ex_event.exception_time.to_date + (@calculate_day -
        @ex_day).days
    else
      @start_exception = ex_event.exception_time.to_date + (Settings.seven +
        @calculate_day - @ex_day).days
    end
  end

  def show_repeat_event event, step, start
    ex_destroy_events = Array.new
    ex_update_events = Array.new
    ex_edit_follow =  Array.new
    repeat_event = [start]

    event.event_exceptions.each do |exception_event|
      if exception_event.delete_only?
        ex_destroy_events << exception_event.exception_time.to_date
      elsif exception_event.delete_all_follow?
        if event.weekly?
          weekly_start_exception exception_event
          ex_destroy_events << @start_exception
        else
          ex_destroy_events << exception_event.exception_time.to_date
        end

        while ex_destroy_events.last <= event.end_repeat.to_date - step
          ex_destroy_events << ex_destroy_events.last + step
        end

      elsif exception_event.edit_only?
        if start.wday == exception_event.exception_time.wday
          ex_update_events << exception_event.exception_time.to_date
          @event_edit = EventFullcalendar.new exception_event
          @event_shows << @event_edit.dup
        end

      elsif exception_event.edit_all_follow?
        if event.weekly?
          weekly_start_exception exception_event
          ex_edit_follow << @start_exception
        else
          ex_edit_follow << exception_event.exception_time.to_date
        end

        while ex_edit_follow.last <= event.end_repeat.to_date - step
          ex_edit_follow << ex_edit_follow.last + step
        end
        @event_edit_follow = EventFullcalendar.new exception_event
      end
    end
    while repeat_event.last <= event.end_repeat.to_date - step
      repeat_event << repeat_event.last + step
    end

    range_repeat_time = repeat_event - ex_destroy_events -
      ex_update_events - ex_edit_follow

    range_repeat_time.each do |repeat_time|
      start_time = @event_temp.start_date.seconds_since_midnight.seconds
      end_time = @event_temp.finish_date.seconds_since_midnight.seconds

      @event_temp.start_date =  repeat_time.to_datetime + start_time
      @event_temp.finish_date = repeat_time.to_datetime + end_time
      @event_temp.id = SecureRandom.urlsafe_base64
      @event_shows << @event_temp.dup
    end

    (ex_edit_follow - ex_destroy_events - ex_update_events).each do |follow_time|
      start_time = @event_edit_follow.start_date.seconds_since_midnight.seconds
      end_time = @event_edit_follow.finish_date.seconds_since_midnight.seconds

      @event_edit_follow.start_date = follow_time.to_datetime + start_time
      @event_edit_follow.finish_date = follow_time.to_datetime + end_time
      @event_edit_follow.id = SecureRandom.urlsafe_base64
      @event_shows << @event_edit_follow.dup
    end
  end

end
