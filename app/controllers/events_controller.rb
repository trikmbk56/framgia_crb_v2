class EventsController < ApplicationController
  load_and_authorize_resource
  before_action :load_calendars, only: [:new, :edit]

  def new
    @event.attendees.build
    @users = User.all
  end

  def create
    @event = current_user.events.build event_params
    if @event.save
      flash[:success] = t "events.flashs.created"
    else
      render :new
    end
    redirect_to user_event_path current_user, @event
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
    @calendars = Calendar.all
  end
end
