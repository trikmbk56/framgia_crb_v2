class NotifyServices
  def initialize event
    @event = event
  end

  def perform
    send_mail_notify
  end

  private
  def send_mail_notify
    time = @event.start_date - Settings.thirty.minutes
    @event.attendees.each do |attendee|
      Delayed::Job.enqueue(EmailNotifyWorker.new(@event.id, attendee.user_id,
        @event.user_id), 0, time)
    end
  end
end
