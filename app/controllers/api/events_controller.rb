class Api::EventsController < ApplicationController
  respond_to :json

  def index
    @events = current_user.events
    @data = @events.map{|event| event.json_data}
    render json: @data
  end

  def update
    @event = Event.find_by id: params[:id]
    render text: @event.update_attributes(title: params[:title], 
      start_date: params[:start], finish_date: params[:end]) ? 
      t("events.flashs.updated") : t("events.flashs.not_updated")
  end

  def destroy
    @event = Event.find_by id: params[:id]
    render text: @event.destroy ? 
      t("events.flashs.deleted") : t("events.flashs.not_deleted")
  end
end
