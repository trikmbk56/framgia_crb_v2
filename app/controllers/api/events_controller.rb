class Api::EventsController < ApplicationController
  respond_to :json

  def index
    if params[:page].present? || params[:calendar_id]
      @data = current_user.events.upcoming_event(params[:calendar_id]).
        page(params[:page]).per Settings.users.upcoming_event
      respond_to do |format|
        format.html {
          render partial: "users/event", locals: {events: @data, user: current_user}
        }
      end
    else
      @events = current_user.events.in_calendars params[:calendars]
      @data = @events.map{|event| event.json_data}
      render json: @data
    end
  end

  def update
    @event = Event.find_by id: params[:id]
    render text: @event.update_attributes(title: params[:title], 
      start_date: params[:start], finish_date: params[:end], 
      all_day: params[:all_day]) ? 
      t("events.flashs.updated") : t("events.flashs.not_updated")
  end

  def destroy
    @event = Event.find_by id: params[:id]
    render text: @event.destroy ? 
      t("events.flashs.deleted") : t("events.flashs.not_deleted")
  end
end
