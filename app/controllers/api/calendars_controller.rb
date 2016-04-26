class Api::CalendarsController < ApplicationController
  respond_to :json

  def update
    calendar = Calendar.find_by id: params[:id]
    calendar.color_id = params[:color_id]
    render text: calendar.update_attributes(color_id: params[:color_id]) ? 
      t("calendars.flashs.updated") : t("calendars.flashs.not_updated")
  end
end
