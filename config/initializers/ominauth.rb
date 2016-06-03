OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
provider :google_oauth2,ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
{
  access_type: "offline",
  skip_jwt: true,
  scope: "userinfo.email calendar"
}
end
