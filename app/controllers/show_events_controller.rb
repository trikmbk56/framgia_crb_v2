class ShowEventsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :load_event, only: :show

  def show
  end
  private
  def load_event
    @event = Event.find_by id: params[:id]
  end
end
