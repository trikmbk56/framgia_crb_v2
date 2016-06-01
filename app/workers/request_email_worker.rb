class RequestEmailWorker
  include Sidekiq::Worker
  def perform user_id, current_user_id
    UserMailer.request_to_share_calendar(user_id,
      current_user_id).deliver
  end
end
