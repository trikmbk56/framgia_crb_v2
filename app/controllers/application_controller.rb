class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include ApplicationHelper

  protect_from_forgery with: :exception
  before_action :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to redirect_url
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
