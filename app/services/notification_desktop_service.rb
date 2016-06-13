class NotificationDesktopService < Struct.new(:event, :action_name)
  include NotifyDesktop

  def perform
    notify_desktop_event event, action_name
  end
end
