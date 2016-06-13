class EventsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: :show
  before_action :load_calendars, only: [:new, :edit]
  before_action :load_attendees, :load_notification_event,
    only: [:new, :edit]
  before_action only: [:edit, :update, :destroy] do
    validate_permission_change_of_calendar @event.calendar
  end

  def new
    if params[:event_id]
      @event = Event.find(params[:event_id]).dup
    end

    Notification.all.each do |notification|
      @event.notification_events.find_or_initialize_by notification: notification
    end

    Settings.event.repeat_data.each do |repeat_on|
      @event.repeat_ons.find_or_initialize_by repeat_on: repeat_on
    end

    # @form = EventForm.new @event
  end

  def create
    @event = current_user.events.new event_params
    respond_to do |format|
      if @event.save
        ChatworkServices.new(@event).perform
        NotificationDesktopService.new(@event, Settings.create_event).perform

        if @event.repeat_type.present?
          FullcalendarService.new.generate_event_delay @event
        else
          NotificationEmailService.new(@event).perform
        end
        NotificationDesktopJob.new(@event, Settings.start_event).perform

        flash[:success] = t "events.flashs.created"
        format.html {redirect_to root_path}
        format.js {@data = @event.json_data(current_user.id)}
      else
        flash[:error] = t "events.flashs.not_created"
        format.html {redirect_to new_event_path}
        format.js
      end
    end
  end

  def edit
    Notification.all.each do |notification|
      @event.notification_events.find_or_initialize_by notification: notification
    end

    RepeatOn.repeat_ons.values.each do |repeat_on|
      @event.repeat_ons.find_or_initialize_by repeat_on: repeat_on
    end

    data = JSON.parse Base64.urlsafe_decode64(params[:fdata])
    @event.start_date = DateTime.strptime(data["start_date"], "%m-%d-%Y %H:%M %p")
    @event.finish_date = DateTime.strptime(data["finish_date"], "%m-%d-%Y %H:%M %p")

    # @form = EventForm.new @event
  end

  def update
    # data = JSON.parse Base64.urlsafe_decode64(params[:fdata])
    # start_date = DateTime.strptime(data["start_date"], "%m-%d-%Y %H:%M %p")
    # finish_date = DateTime.strptime(data["finish_date"], "%m-%d-%Y %H:%M %p")

    # if @event.start_date == start_date
    #   @event.assign_attributes event_params
    # else
    #   @event = Event.new event_params.merge({parent_id: @event.id})
    #   @event.exception_time = @event.start_date
    #   @event.exception_type = "edit_only"
    # end

    # if @event.save
    #   NotificationDesktopService.new(@event, current_user).perform
    #   EventExceptionService.new(@event.parent, event_params).update_event_exception
    #   flash[:success] = t "events.flashs.updated"
    #   redirect_to root_path
    # else
    #   render :edit
    # end

    params[:event] = params[:event].merge({
      exception_time: event_params[:start_date],
      start_repeat: event_params[:start_date],
      end_repeat: event_params[:end_repeat].nil? ? @event.end_repeat : (event_params[:end_repeat].to_date + 1.days)
    })

    EventExceptionService.new(@event, event_params, {}).update_event_exception
    flash[:success] = t "events.flashs.updated"
    redirect_to root_path
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
end
