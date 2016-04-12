class CalendarsController < ApplicationController
  load_and_authorize_resource

  def destroy
    if @calendar.destroy
      flash[:success] = t "calendars.deleted"
    else
      flash[:danger] = t "calendars.not_deleted"
    end
    redirect_to user_calendars_path current_user
  end
end
