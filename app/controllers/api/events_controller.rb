class Api::EventsController < ApplicationController
  respond_to :json

  def index
    @events = current_user.events
    @data = @events.map{|event| event.json_data}
    render json: @data
  end
end
