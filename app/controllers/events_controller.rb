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

    event_conflic = false
    @calendar = Calendar.find_by id: event_params[:calendar_id]
    if !@calendar.parent?
      create_calendar_all_event_array
      @array.each do |element|
        if conflic_time?(@event, element) && conflic_day?(@event, element)
          event_conflic = true
          flash[:error] = t "events.flashs.not_created"
          break
        end
      end
    end

    respond_to do |format|
      if !event_conflic && @event.save
        ChatworkServices.new(@event).perform
        NotificationDesktopService.new(@event, current_user).perform

        if valid_params? params[:repeat_ons], event_params[:repeat_type]
          @repeat_ons = params[:repeat_ons]
          @repeat_ons.each do |repeat_on|
            RepeatOn.create! repeat_on: repeat_on, event_id: @event.id
          end
        end

        if @event.repeat_type.present?
          FullcalendarService.new.generate_event_delay @event
        else
          NotificationEmailService.new(@event).perform
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
      NotificationDesktopService.new(@event, current_user).perform
      flash[:success] = t "events.flashs.updated"
      redirect_to user_event_path current_user, @event
    else
      render :edit
    end
  end

  def destroy
    if @event.destroy
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

  def create_calendar_all_event_array
    @array = []
    @calendar.events.no_parent.each do |event|
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
            break
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
    if (event_exception.exception_time - 1.days).end_of_day >= @event_copy.start_repeat
      new_event = @event_copy.dup
      new_event.end_repeat = event_exception.exception_time - 1.days
      @array << new_event
    end
    @event_copy = event_exception.dup
    @event_copy.end_repeat -= 1.days
  end

  def conflic_day? event1, event2
    unit1 = get_unit event1
    unit2 = get_unit event2
    start1 = event1.start_repeat
    start2 = event2.start_repeat
    while start1 <= event1.end_repeat.end_of_day
      start2 = event2.start_repeat
      while start2 <= event2.end_repeat.end_of_day
        if start1.strftime("%D") == start2.strftime("%D")
          return true
        end
        start2 += unit2
      end
      start1 += unit1
    end
  end

  def get_unit event
    case event.repeat_type
    when "daily"
      return event.repeat_every.days
    when "weekly"
      return event.repeat_every.weeks
    when "monthly"
      return event.repeat_every.months
    when "yearly"
      return event.repeat_every.years
    end
    1.day
  end

  def conflic_time? event1, event2
    event1_start_time = convert_time_to_second event1.start_date
    event1_finish_time = convert_time_to_second event1.finish_date
    event2_start_time = convert_time_to_second event2.start_date
    event2_finish_time = convert_time_to_second event2.finish_date
    (event1_start_time > event2_start_time && event1_start_time < event2_finish_time) ||
      (event1_finish_time > event2_start_time && event1_finish_time < event2_finish_time)
  end

  def convert_time_to_second time
    hour = time.hour
    min = time.min
    sec = time.sec
    hour*1.hour.to_i + min*1.minute.to_i + sec
  end
end
