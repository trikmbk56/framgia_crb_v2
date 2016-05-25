class Api::ParticularEventsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def index
    calendar = Calendar.find_by id: params[:calendar_id]
    events = calendar.events
    if !user_signed_in? and calendar.no_public?
      render text: t("events.popup.fail")
    elsif user_signed_in? and calendar.no_public? and
        current_user.id != calendar.user_id
      render text: t("events.popup.fail")
    else
      render json: events
    end
  end

  def show
    @event = Event.find_by id: params[:id]
    respond_to do |format|
      format.html {
        render partial: "events/popup_event",
          locals: {user: current_user, title: @event.title,
          event: @event, start_date: params[:start], finish_date: params[:end]}
      }
    end
  end
end
