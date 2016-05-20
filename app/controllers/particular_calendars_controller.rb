class ParticularCalendarsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :load_calendar

  def show
    @status = @calendar.status
    if user_signed_in?
      @user_calendar = UserCalendar.find_by user_id: current_user.id,
        calendar_id: @calendar.id
    end
  end

  private
  def load_calendar
    @calendar = Calendar.find_by id: params[:id]
  end
end
