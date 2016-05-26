class UpdateEventExceptionServices

  def initialize event, params
    @exception_type = params[:exception_type]
    @event = event
    @event_params = params.permit :id, :title, :all_day, :start_repeat,
      :end_repeat, :start_date, :finish_date, :exception_type, :exception_time
    @event_update_params = params.permit :title, :all_day, :start_repeat,
      :end_repeat, :start_date, :finish_date, :exception_type, :exception_time
    @is_drop = params[:is_drop]
  end

  def update_event_exception
    if @is_drop == "0"
      case @event_params[:exception_type]
      when ""
        @event.update_attributes @event_params
      when "edit_all"
        initial_value @event_params[:start_date], @event_params[:finish_date], @event
        @event_exception_edits = Event.exception_edits @event.id
        update_attributes_event @event
        @event_exception_edits.each do |event|
          update_attributes_event event
        end
      when "edit_only"
        event_exception = @event.event_exceptions.event_exception_at_time 2,
          @event_params[:start_date].to_datetime.beginning_of_day,
          @event_params[:start_date].to_datetime.end_of_day
        save_this_event_exception event_exception

      when "edit_all_follow"
        initial_value @event_params[:start_date], @event_params[:finish_date], @event
        event_exception = @event.event_exceptions.event_exception_at_time [2, 3],
          @event_params[:start_date].to_datetime.beginning_of_day,
          @event_params[:start_date].to_datetime.end_of_day
        save_this_event_exception event_exception

        if event = event_exception_pre_nearest
          event.update_attributes end_repeat:
            DateTime.parse(@event_params[:start_date]) + 1.days
        else
          @event.update_attributes end_repeat:
            DateTime.parse(@event_params[:start_date]) + 1.days
        end
        event_after_exceptions = @event.event_exceptions.
          all_event_after_date @event_params[:start_date].to_datetime
        event_after_exceptions.each do |event|
          update_attributes_event event
        end
        event_allfollow_exceptions = @event.event_exceptions.
          event_follow_after_date @event_params[:start_date].to_datetime
        event_allfollow_exceptions.destroy_all
      end
    else
    end
  end

  private
  def initial_value start_date, finish_date, event
    @pre_start_date = event.start_date
    @pre_finish_date = event.finish_date
    @start_date = DateTime.parse(start_date)
    @finish_date = DateTime.parse(finish_date)

    @hour_start = @start_date.strftime("%H").to_i
    @minute_start = @start_date.strftime("%M").to_i
    @second_start = @start_date.strftime("%S").to_i
    @hour_end = @finish_date.strftime("%H").to_i
    @minute_end = @finish_date.strftime("%M").to_i
    @second_end = @finish_date.strftime("%S").to_i
  end

  def update_attributes_event event
    event.update_attributes(
      title: @event_params[:title],
      start_date: (event.start_date.change(
      {hour: @hour_start, min: @minute_start, sec: @second_start})),
      finish_date: (event.finish_date.change(
      {hour: @hour_end, min: @minute_end, sec: @second_end})))
  end

  def save_this_event_exception event_exception
    if event_exception
      event_exception.update_attributes @event_update_params
    else
      @event_params[:parent_id] = @event.id
      @event_params[:id] = nil
      @event.dup.update_attributes @event_params
    end
  end

  def event_exception_pre_nearest
    @event.event_exceptions.event_pre_nearest(@event_params[:start_date]).
      order(start_date: :desc).first
  end
end
