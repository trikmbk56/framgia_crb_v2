class GoogleCalendarsController < ApplicationController
  def create
    @auth = request.env["omniauth.auth"]
    @token = @auth["credentials"]["token"]
    client = Google::APIClient.new
    client.authorization.access_token = @token
    service = client.discovered_api("calendar", "v3")
    SyncGoogleCalendarServices.new(client, service, current_user, @token).pull_events
    sync_google = SyncGoogleCalendarServices.new(client, service, current_user, @token)
    sync_google.push_event if response.status.eql? Settings.response_status_Ok

    redirect_to root_url
  end
end
