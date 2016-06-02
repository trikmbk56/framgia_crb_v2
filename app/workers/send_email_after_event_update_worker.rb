class SendEmailAfterEventUpdateWorker
  include Sidekiq::Worker
  def perform(event_before_update_id, event_after_update_id,
    start_date_before, finish_date_before)
    UserMailer.send_email_after_event_update(event_before_update_id,
      event_after_update_id, start_date_before, finish_date_before).deliver
  end
end
