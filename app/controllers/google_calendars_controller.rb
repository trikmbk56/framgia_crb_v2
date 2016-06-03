class GoogleCalendarsController < ApplicationController
  def create
    @auth = request.env["omniauth.auth"]
    @token = @auth["credentials"]["token"]
    client = Google::APIClient.new
    client.authorization.access_token = @token
    service = client.discovered_api("calendar", "v3")
    event = {
      'summary' => 'Test',
      'location' => 'Keang Nam',
      'start' => {
         'dateTime' => '2016-06-03T10:00:00.000-07:00'
      },
      'end' => {
         'dateTime' => '2016-06-03T10:25:00.000-07:00'
      }
    }
    @result = client.execute(:api_method => service.events.insert,
      :parameters => {'calendarId' => 'nguyenduyx188@gmail.com', 'sendNotifications' => true},
      :body => JSON.dump(event),
      :headers => {'Content-Type' => 'application/json'})
    redirect_to root_url
  end
end
