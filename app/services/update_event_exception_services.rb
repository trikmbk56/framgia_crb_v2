class UpdateEventExceptionServices

  def initialize exception_type, event, event_params
    @exception_type = exception_type
    @event = event
    @event_params = event_params
  end

  def update_event_exception
    if @exception_type == "edit_all"
      initial_value @event_params, @event
      @event_exception_edits = Event.exception_edits @event_params[:id]

      if @event_params[:title] != @event.title
        @event.update_attributes title: @event_params[:title]
        @event_exception_edits.each do |event|
          event.update_attributes title: @event_params[:title]
        end
      elsif (@pre_start_date.strftime("%T") != @start_date.strftime("%T") ||
        @pre_finish_date.strftime("%T") != @finish_date.strftime("%T"))
        @event.update_attributes(
          start_date: (@event.start_date + @value_offset_start.minutes),
          finish_date: (@event.finish_date + @value_offset_end.minutes))
        @event_exception_edits.each do |event|
          event.update_attributes(
            start_date: (event.start_date + @value_offset_start.minutes),
            finish_date: (event.finish_date + @value_offset_end.minutes))
        end
      end
    else
      @event.update_attributes @event_params
    end
  end

  private
  def initial_value event_params, event
    @pre_start_date = event.start_date
    @pre_finish_date = event.finish_date
    @start_date = DateTime.parse(event_params[:start_date])
    @finish_date = DateTime.parse(event_params[:finish_date])
    @value_offset_start = calculator_diffrence_values @start_date, @pre_start_date
    @value_offset_end = calculator_diffrence_values @finish_date, @pre_finish_date
  end

  def calculator_diffrence_values datetime, pre_datetime
    ((DateTime.parse(datetime.strftime("%T")) -
      DateTime.parse(pre_datetime.strftime("%T"))) * Settings.minutes_in_day).to_i
  end

end
