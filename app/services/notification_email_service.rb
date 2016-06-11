class NotificationEmailService
  def initialize event, event_fullcalendar = nil
    @event = event
    @event_fullcalendar = event_fullcalendar
  end

  def perform
    send_notification
  end

  private
  def send_notification
    if @event_fullcalendar.present?
      time = @event_fullcalendar.start_date - Settings.thirty.minutes
    else
      time =  @event.start_date - Settings.thirty.minutes
    end
    Delayed::Job.enqueue ChatworkJob.new(@event), 0, time
    @event.attendees.each do |attendee|
      Delayed::Job.enqueue(EmailNotifyWorker.new(@event.id, attendee.user_id,
        @event.user_id), 0, time)
    end
  end
end
