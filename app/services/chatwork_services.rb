class ChatworkServices
  def initialize event
    @event = event
  end

  def send_messages
    if @event.attendees
      @event.attendees.each do |attendee|
        attendee_user = attendee.user
        ChatWork::Message.create(room_id: Settings.room_id,
          body: "[To:#{attendee_user.chatwork_id}] #{attendee_user.name}
          #{I18n.t("events.message.chatwork_create")}")
      end
    end
  end
end
