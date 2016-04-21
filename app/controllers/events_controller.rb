class EventsController < ApplicationController
  load_and_authorize_resource
  before_action :load_calendars, only: [:new, :edit]
  before_action :format_date, only: [:create, :update]
  before_action :load_attendees, only: [:new, :edit, :show]

  def show
    @attendees = @event.attendees
  end

  def create
    @event = current_user.events.new event_params
    respond_to do |format|
      if @event.save
        flash[:success] = t "events.flashs.created"
        format.html do
          redirect_to user_event_path current_user, @event
        end
        format.js
      else
        flash[:error] = t "events.flashs.not_created"
        format.html render :new
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
    @calendars = Calendar.all
  end

  def load_attendees
    @event.attendees.build
    @users = User.all
    @attendee = Attendee.new
  end
end
