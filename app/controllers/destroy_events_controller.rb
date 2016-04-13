class DestroyEventsController < ApplicationController
  before_action :load_calendar, only: :destroy

  def destroy
    if @calendar.events.destroy_all
      flash[:success] = t "calendars.events.cleared_event"
    else
      flash[:danger] = t "calendars.events.not_cleared_event"
    end
    redirect_to root_path
  end

  private
  def load_calendar
    @calendar = Calendar.find_by params[:id]
  end
end
