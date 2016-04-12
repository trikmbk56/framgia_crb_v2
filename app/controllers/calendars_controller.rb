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

  def create
    @calendar.user_id = current_user
    if @calendar.save
      flash[:success] = t "calendar.success_calendar"
      redirect_to calendars_path
    else
      flash[:danger] = t "calendar.danger_calendar"
      render :new
    end
  end

  private
  def calendar_params
    params.require(:calendar).permit Calendar::ATTRIBUTES_PARAMS
  end
end
