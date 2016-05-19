class ShareCalendarMailer < ApplicationMailer
  default from: "no_reply@framgia.com"

  def request_to_share_calendar user, current_user
    @user = user
    @current_user = current_user
    mail to: @user.email, subject: t("calendars.flashs.request_to_share_calendar")
  end
end
