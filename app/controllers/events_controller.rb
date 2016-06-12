class EventsController < ApplicationController
  load_and_authorize_resource
  before_action :load_calendars, only: [:new, :edit]
  before_action :load_attendees, :load_notification_event,
    only: [:new, :edit, :show]
  before_action only: [:edit, :update, :destroy] do
    validate_permission_change_of_calendar @event.calendar
  end
  before_action only: [:show] do
    validate_permission_see_detail_of_calendar @event.calendar
  end

  def new
    if params[:event_id]
      @event = Event.find(params[:event_id]).dup
    end
  end

  def show
    @attendees = @event.attendees
    @notification_events = @event.notification_events
  end

  def create
    create_calendar_all_event_array event_params[:calendar_id]
    @event = current_user.events.new event_params
    if event_params[:start_repeat].blank?
      @event.start_repeat = event_params[:start_date]
    else
      @event.start_repeat = event_params[:start_repeat]
    end
    if event_params[:end_repeat].blank?
      @event.end_repeat = event_params[:finish_date].to_date
    else
      @event.end_repeat = event_params[:end_repeat].to_date
    end

    respond_to do |format|
      if @event.save
        ChatworkServices.new(@event).perform

        if valid_params? params[:repeat_ons], event_params[:repeat_type]
          @repeat_ons = params[:repeat_ons]
          @repeat_ons.each do |repeat_on|
            RepeatOn.create! repeat_on: repeat_on, event_id: @event.id
          end
        end

        if @event.repeat_type.present?
          GenerateEventFullcalendarServices.new.generate_event_delay @event
        else
          NotifyServices.new(@event).perform
        end

        flash[:success] = t "events.flashs.created"
        format.html do
          redirect_to user_event_path current_user, @event
        end
        format.js {@data = @event.json_data(current_user.id)}
      else
        flash[:error] = t "events.flashs.not_created"
        format.html do
          redirect_to new_user_event_path current_user
        end
        format.js
      end
    end
  end

  def edit
    @repeat_ons = @event.repeat_ons
  end

  def update
    if @event.update_attributes event_params
      GoogleCalendarService.update_event @event
      flash[:success] = t "events.flashs.updated"
      redirect_to user_event_path current_user, @event
    else
      render :edit
    end
  end

  def destroy
    if @event.destroy
      GoogleCalendarService.delete_event @event
      flash[:success] = t "events.flashs.deleted"
    else
      flash[:danger] = t "events.flashs.not_deleted"
    end
    redirect_to root_path
  end

  private
  def event_params
    params.require(:event).permit Event::ATTRIBUTES_PARAMS
  end

  def load_calendars
    @calendars = current_user.manage_calendars
  end

  def load_attendees
    @users = User.all
    @attendee = Attendee.new
  end

  def load_notification_event
    @notifications = Notification.all
    @notification_event = NotificationEvent.new
  end

  def valid_params? repeat_on, repeat_type
    repeat_on.present? && repeat_type == Settings.repeat.repeat_type.weekly
  end

  def create_calendar_all_event_array calendar_id
    calendar = Calendar.find_by id: calendar_id
    @array = []
    calendar.events.each do |event|
      if event.start_repeat.strftime("%D") == event.end_repeat.strftime("%D")
        @array << event
      else
        @event_copy = event.dup
        event.event_exceptions.sort_by_start_date.each do |event_exception|
          case event_exception.exception_type
          when "delete_only"
            analyze_repeat_event_when_delete_only event_exception
          when "delete_all_follow"
            analyze_repeat_event_when_delete_all_follow event_exception
          when "edit_only"
            analyze_repeat_event_when_edit_only event_exception
          when "edit_all_follow"
            analyze_repeat_event_when_edit_all_follow event_exception
          end
          if @event_copy.start_repeat.beginning_of_day > @event_copy.end_repeat
            break
          end
        end
        if @event_copy.start_repeat.beginning_of_day <= @event_copy.end_repeat
          @array << @event_copy
        end
      end
    end
    binding.pry
  end

  def analyze_repeat_event_when_delete_only event_exception
    if (event_exception.exception_time - 1.days).end_of_day >= @event_copy.start_repeat
      new_event = @event_copy.dup
      new_event.end_repeat = event_exception.exception_time - 1.days
      @array << new_event
    end
    @event_copy.start_repeat = event_exception.exception_time + 1.days
  end

  def analyze_repeat_event_when_delete_all_follow event_exception
    @event_copy.end_repeat = event_exception.exception_time - 1.days
  end

  def analyze_repeat_event_when_edit_only event_exception
    if (event_exception.exception_time - 1.days).end_of_day >= @event_copy.start_repeat
      new_event = @event_copy.dup
      new_event.end_repeat = event_exception.exception_time - 1.days
      @array << new_event
    end
    new_event = event_exception.dup
    new_event.start_repeat = event_exception.exception_time
    new_event.end_repeat = event_exception.exception_time
    @array << new_event
    @event_copy.start_repeat = event_exception.exception_time + 1.days
  end

  def analyze_repeat_event_when_edit_all_follow event_exception
    binding.pry
    if (event_exception.exception_time - 1.days).end_of_day >= @event_copy.start_repeat
      new_event = @event_copy.dup
      new_event.end_repeat = event_exception.exception_time - 1.days
      @array << new_event
    end
    new_event = event_exception.dup
    new_event.start_repeat = event_exception.exception_time
    new_event.end_repeat = @event_copy.end_repeat
    @event_copy = new_event
    binding.pry
  end
end
