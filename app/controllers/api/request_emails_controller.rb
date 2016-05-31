class Api::RequestEmailsController < ApplicationController
  def new
    @user = User.find_by email: params[:request_email]
    if @user
      RequestEmailWorker.perform_async @user.id, current_user.id
      render text: t("calendars.flashs.email_sent")
    else
      render text: t("calendars.flashs.email_not_exsist")
    end
  end
end
