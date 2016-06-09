class GoogleCalendarsController < ApplicationController
  def create
    @user = User.find_for_google_oauth2 request.env["omniauth.auth"], current_user
    push = request.env["omniauth.params"]["push"]
    pull = request.env["omniauth.params"]["pull"]
    @auth = request.env["omniauth.auth"]
    @token = @auth["credentials"]["token"]
    client = Google::APIClient.new
    client.authorization.access_token = @token
    service = client.discovered_api("calendar", "v3")
    sync_google = SyncGoogleCalendarServices.new(client, service, current_user, @token)
    if response.status.eql? Settings.response_status_Ok
      sync_google.push_events if push == Settings.sync_params_true
      sync_google.pull_events if pull == Settings.sync_params_true
    end
    redirect_to root_url
  end
end
