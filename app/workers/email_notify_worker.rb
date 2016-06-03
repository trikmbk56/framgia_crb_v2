class EmailNotifyWorker < Struct.new :event_id, :user_id, :current_user_id
  include Sidekiq::Worker
  def perform
    UserMailer.send_email_notify_delay(event_id, user_id,
      current_user_id).deliver
  end
end
