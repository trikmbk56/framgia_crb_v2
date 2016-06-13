class Api::EventsController < ApplicationController
  respond_to :json
  before_action only: [:edit, :update, :destroy] do
    load_event
    validate_permission_change_of_calendar @event.calendar
  end

  def index
    if params[:page].present? || params[:calendar_id]
      @data = current_user.events.upcoming_event(params[:calendar_id])
        .page(params[:page]).per Settings.users.upcoming_event
      respond_to do |format|
        format.html {
          render partial: "users/event", locals: {events: @data, user: current_user}
        }
      end
    else
      @events = Event.in_calendars params[:calendars]
      @event_exceptions = @events.has_exceptions
      @data = FullcalendarService.new(@events, current_user,
        @event_exceptions).repeat_data
      render json: @data
    end
  end

  def update
    params[:event] = params[:event].merge({
      exception_time: event_params[:start_date],
      start_repeat: event_params[:start_date],
      end_repeat: event_params[:end_repeat].nil? ? @event.end_repeat : (event_params[:end_repeat].to_date + 1.days)
    })

    argv = {
      is_drop: params[:is_drop],
      start_time_before_drag: params[:start_time_before_drag],
      finish_time_before_drag: params[:finish_time_before_drag]
    }

    EventExceptionService.new(@event, event_params, argv).update_event_exception
    render text: t("events.flashs.updated")
  end

  def show
    @event = Event.find_by id: params[:id]

    locals = {
      start_date: params[:start],
      finish_date: params[:end]
    }.to_json

    respond_to do |format|
      format.html {
        render partial: "events/popup_event",
          locals: {
            user: current_user,
            event: @event,
            title: params[:title],
            start_date: params[:start],
            finish_date: params[:end],
            fdata: Base64.urlsafe_encode64(locals)
          }
      }
    end
  end

  def destroy
    @event = Event.find_by id: params[:id]
    if @event.repeat_type.nil? || (@event.repeat_type &&
      params[:exception_type] == "delete_all" && @event.parent_id.nil?)
      destroy_event @event
    elsif params[:exception_type] == "delete_all"
      destroy_event @event.event_parent
      render text: t("events.flashs.deleted")
    else
      destroy_event_repeat @event, params[:exception_type],
        params[:exception_time], params[:start_date_before_delete],
        params[:finish_date_before_delete]
      render text: t("events.flashs.deleted")
    end
  end

  private
  def event_params
    params.require(:event).permit Event::ATTRIBUTES_PARAMS
  end

  def exception_params
    params.permit :title, :all_day, :start_repeat, :end_repeat,
      :start_date, :finish_date, :exception_type, :exception_time, :parent_id
  end

  def load_event
    @event = Event.find_by id: params[:id]
  end

  def destroy_event event
    if event.destroy
      render text: t("events.flashs.deleted")
    else
      render text: t("events.flashs.not_deleted")
    end
  end

  def destroy_event_repeat(event, exception_type, exception_time,
    start_date_before_delete, finish_date_before_delete)
    if @event.parent_id.nil?
      parent = @event
    else
      parent = @event.event_parent
    end
    event_exception = parent.event_exceptions.find_by "exception_time >= ? and
      exception_time <= ?", exception_time.to_datetime.beginning_of_day,
      exception_time.to_datetime.end_of_day
    if event_exception
      event_exception.update_attributes exception_type: exception_type
    else
      event.dup.update_attributes(exception_type: exception_type,
        exception_time: exception_time, parent_id: parent.id,
        start_date: start_date_before_delete, finish_date: finish_date_before_delete)
    end
  end
end
