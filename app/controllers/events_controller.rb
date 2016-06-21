class EventsController < ApplicationController
  include TimeOverlapForUpdate
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: :show
  before_action :load_calendars, only: [:new, :edit]
  before_action :load_attendees, :load_notification_event,
    only: [:new, :edit]
  before_action only: [:edit, :update, :destroy] do
    validate_permission_change_of_calendar @event.calendar
  end

  def new
    if params[:fdata]
      hash_params = JSON.parse(Base64.decode64 params[:fdata]) rescue {"event": {}}
      @event = Event.new hash_params["event"]
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
    time_overlap_for_create
    if @time_overlap.nil?
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
    else
      respond_to do |format|
        format.html {redirect_to :back}
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

    # data = JSON.parse(Base64.urlsafe_decode64 params[:fdata]) rescue {"event": {}}
    # @event.start_date = DateTime.strptime(data["start_date"], "%m-%d-%Y %H:%M %p")
    # @event.finish_date = DateTime.strptime(data["finish_date"], "%m-%d-%Y %H:%M %p")

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

    event = Event.new event_params
    if @event.event_parent.nil?
      event.parent_id = @event.id
    else
      event.parent_id = @event.event_parent.id
    end
    event.calendar_id = @event.calendar_id

    if overlap_when_update? event
      flash[:error] = t "events.flashs.not_updated_because_overlap"
    else
      EventExceptionService.new(@event, event_params, {}).update_event_exception
      flash[:success] = t "events.flashs.updated"
    end
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

  def time_overlap_for_create
    event_overlap = EventOverlap.new(@event)
    if !event_overlap.overlap?
      @time_overlap = nil
    elsif @event.start_repeat.nil? ||
      (@event.start_repeat.to_date >= event_overlap.time_overlap.to_date)
      @time_overlap = Settings.full_overlap
    else
      @time_overlap = (event_overlap.time_overlap - 1.day).to_s
      @event_params = event_params
      @event_params[:end_repeat] = @time_overlap
    end
  end
end
