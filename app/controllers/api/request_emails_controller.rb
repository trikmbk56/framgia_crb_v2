class Api::RequestEmailsController < ApplicationController
  def new
    @user = User.find_by email: params[:request_email]
    if @user
      ShareCalendarMailer.request_to_share_calendar(@user, current_user).deliver
      render text: t("calendars.flashs.email_sent")
    else
      render text: t("calendars.flashs.email_not_exsist")
    end
  end
end
