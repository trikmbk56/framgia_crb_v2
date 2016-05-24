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
      when "edit_only"
        event_exception = @event.event_exceptions.find_by  "exception_type = ? and
          exception_time >= ? and exception_time <= ?", 2, 
          @event_params[:start_date].to_datetime.beginning_of_day, 
          @event_params[:start_date].to_datetime.end_of_day
        if event_exception
            event_exception.update_attributes @event_update_params
        else
          @event_params[:parent_id] = @event.id
          @event_params[:id] = nil
          @event.dup.update_attributes @event_params
        end
      when "edit_all_follow"
        
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
    @value_offset_start = calculator_diffrence_values @start_date, @pre_start_date
    @value_offset_end = calculator_diffrence_values @finish_date, @pre_finish_date
  end

  def calculator_diffrence_values datetime, pre_datetime
    ((DateTime.parse(datetime.strftime("%T")) -
      DateTime.parse(pre_datetime.strftime("%T"))) * Settings.minutes_in_day).to_i
  end

end
