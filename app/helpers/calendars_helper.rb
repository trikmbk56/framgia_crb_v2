module CalendarsHelper
  def btn_via_permission user, event
    user_calendar = user.user_calendars.find_by calendar: event.calendar
    btn = render "events/buttons/btn_copy", user_id: user.id, event_id: event.id
    btn = "" if event.calendar.is_default 
    if Settings.permissions_can_make_change.include? user_calendar.permission_id 
      btn += render "events/buttons/btn_cancel"
      btn += render "events/buttons/btn_edit", 
        url: "/users/#{user.id}/events/#{event.id}/edit";
      btn += render "events/buttons/btn_save"
      btn += render "events/buttons/btn_delete"
    elsif user_calendar.permission_id == 3
      btn += render "events/buttons/btn_detail",
        url: "/users/#{user.id}/events/#{event.id}";
    end
    btn.html_safe
  end

  def confirm_popup_repeat_events action
    render "events/confirm_popup_repeat", action: action
  end
end
