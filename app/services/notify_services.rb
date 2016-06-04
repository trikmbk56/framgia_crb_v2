class NotifyServices
  def initialize event, event_fullcalendar = nil
    @event = event
    @event_fullcalendar = event_fullcalendar
  end

  def perform
    send_mail_notify
  end

  private
  def send_mail_notify
    if @event_fullcalendar.present?
      time = @event_fullcalendar.start_date - Settings.thirty.minutes
    else
      time =  @event.start_date - Settings.thirty.minutes
    end
    @event.attendees.each do |attendee|
      Delayed::Job.enqueue(EmailNotifyWorker.new(@event.id, attendee.user_id,
        @event.user_id), 0, time)
    end
  end
end
