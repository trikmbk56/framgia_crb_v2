class EventsController < ApplicationController
  load_and_authorize_resource
  before_action :load_calendars, only: [:new, :edit]
  before_action :format_date, only: [:create, :update]
  before_action :load_attendees, only: [:new, :edit]

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
  end

  def format_date
    start_time = params[:start_time]
    finish_time = params[:finish_time]
    start_date = params[:start_date]
    finish_date = params[:finish_date]
    params[:event][:start_date] = "#{start_date} #{start_time}".to_datetime
    params[:event][:finish_date] = "#{finish_date} #{finish_time}".to_datetime
  end
end
