class ChatworkJob < Struct.new(:event)
  def perform
    send_notification_messages event
  end

  private
  def send_notification_messages event
    if event.attendees
      event.attendees.each do |attendee|
        ChatWork::Message.create(room_id: Settings.room_id,
          body: "[To:#{attendee.chatwork_id}] #{attendee.user_name}
          #{I18n.t("events.message.event_start", event: event.title)}")
      end
    end
  end
end
