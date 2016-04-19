class Api::EventsController < ApplicationController
  respond_to :json

  def index
    @events = current_user.events
    @data = @events.map{|event| event.json_data}
    render json: @data
  end

  def destroy
    @event = Event.find_by params[:id]
    render text: @event.destroy ? t("events.flashs.deleted") : t("events.flashs.not_deleted")
  end
end
