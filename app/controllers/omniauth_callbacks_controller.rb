class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.find_for_google_oauth2 request.env["omniauth.auth"], current_user
    redirect_to root_url
  end
end
