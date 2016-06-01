class UserMailer < ApplicationMailer
  default from: "no_reply@framgia.com"

  def request_to_share_calendar user_id, current_user_id
    @user = User.find user_id
    @current_user = User.find current_user_id
    mail to: @user.email, subject: t("calendars.flashs.request_to_share_calendar")
  end

  def send_email_notify_event event_id, user_id, current_user_id
    @event = Event.find_by_id event_id
    @user = User.find user_id
    @current_user = User.find current_user_id
    mail to: @user.email, subject: t("events.mailer.join_event")
  end
end
