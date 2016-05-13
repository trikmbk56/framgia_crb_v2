class EventsController < ApplicationController
  load_and_authorize_resource
  before_action :load_calendars, only: [:new, :edit]
  before_action :load_attendees, only: [:new, :edit, :show]

  def show
    @attendees = @event.attendees
  end

  def create
    @event = current_user.events.new event_params
    if event_params[:start_repeat].nil?
      @event.start_repeat = event_params[:start_date]
    else
      @event.start_repeat = event_params[:start_repeat]
    end
    if event_params[:end_repeat].nil?
      @event.end_repeat = event_params[:finish_date].to_date + 1.days
    else
      @event.end_repeat = event_params[:end_repeat].to_date + 1.days
    end
  
    respond_to do |format|
      if @event.save
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

  def update
    if @event.update_attributes event_params
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
    @calendars = current_user.calendars
  end

  def load_attendees
    @users = User.all
    @attendee = Attendee.new
  end
end
