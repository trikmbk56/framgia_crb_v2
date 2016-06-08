class GoogleCalendarsController < ApplicationController
  def create
    @auth = request.env["omniauth.auth"]
    @token = @auth["credentials"]["token"]
    client = Google::APIClient.new
    client.authorization.access_token = @token
    service = client.discovered_api("calendar", "v3")

    SyncGoogleCalendarServices.new(client, service, current_user).pull_events
    redirect_to root_url
  end
end
