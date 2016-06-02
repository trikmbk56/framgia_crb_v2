class SendEmailWorker
  include Sidekiq::Worker
  def perform event_id, user_id, current_user_id
    UserMailer.send_email_notify_event(event_id, user_id,
      current_user_id).deliver
  end
end
