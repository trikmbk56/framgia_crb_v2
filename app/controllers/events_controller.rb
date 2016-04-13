class EventsController < ApplicationController
  load_and_authorize_resource

  def create
    @event = current_user.events.build event_params
    if @event.save
      flash[:success] = t "flashs.created"
    else
      render :new
    end
    redirect_to events_path
  end

  def update
    if @event.update_attributes event_params
      flash[:success] = t "flashs.updated"
      redirect_to events_path
    else
      render :edit
    end
  end

  private
  def event_params
    params.require(:event).permit Event::ATTRIBUTES_PARAMS
  end
end
