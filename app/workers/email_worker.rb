class EmailWorker
  include Sidekiq::Worker
  def perform agrv = {}, ptype = nil
    perform_update_event if ptype = :update_event
    perform_delete_event if ptype == :delete_event
    perform_normaly if ptype.nil?
  end

  private
  def perform_normaly
    event_id = argv[:event_id]
    user_id = argv[:user_id]
    current_user_id = argv[:current_user_id]
    UserMailer.send_email_notify_event(event_id, user_id, current_user_id).deliver
  end

  def perform_delete_event
    user_id = argv[:user_id]
    event_title = argv[:event_title]
    event_start_date = argv[:event_start_date]
    event_finish_date = argv[:event_finish_date]
    event_exception_type = argv[:event_exception_type]

    UserMailer.send_email_after_delete_event(user_id, event_title, event_start_date,
      event_finish_date, event_exception_type).deliver
  end

  def perform_update_event
    event_before_update_id = argv[:event_before_update_id]
    event_after_update_id = argv[:event_after_update_id]
    start_date_before = argv[:start_date_before]
    finish_date_before = argv[:finish_date_before]

    UserMailer.send_email_after_event_update(event_before_update_id,
      event_after_update_id, start_date_before, finish_date_before).deliver
  end
end
