class ChatworkServices
  def initialize event
    @event = event
  end

  def perform
    send_messages
    create_tasks
  end

  private
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

  def create_tasks
    if @event.room_id && @event.attendees
      unix_time_limit = Time.parse(@event.start_date.to_s).to_i
      to_ids = get_chatwork_ids
      ChatWork::Task.create(
        room_id: @event.room_id,
        body: @event.task_content,
        to_ids: to_ids,
        limit: unix_time_limit
      )
    end
  end

  def get_chatwork_ids
    @event.attendees.map{|attendee| attendee.chatwork_id}.join(", ")
  end
end
