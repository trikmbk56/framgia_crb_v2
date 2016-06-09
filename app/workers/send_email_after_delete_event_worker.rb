class SendEmailAfterDeleteEventWorker
  include Sidekiq::Worker
  def perform(user_id, event_title, event_start_date, event_finish_date, event_exception_type)
    UserMailer.send_email_after_delete_event(user_id, event_title, event_start_date,
      event_finish_date, event_exception_type).deliver
  end
end
