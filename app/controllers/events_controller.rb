class EventsController < ApplicationController
  load_and_authorize_resource

  def create
    @event = Event.new event_params
    if @event.save
      flash[:success] = t "flashs.created"
    else
      render :new
    end
    redirect_to events_path
  end

  private
  def event_params
    params.require(:event).permit Event::ATTRIBUTES_PARAMS
  end
end
