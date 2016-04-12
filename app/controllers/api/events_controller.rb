class Api::EventsController < ApplicationController
  respond_to :json

  def index
    @events = Event.my_events current_user.id
    @data = @events.map{|event| event.json_data}
    render json: @data
  end
end
