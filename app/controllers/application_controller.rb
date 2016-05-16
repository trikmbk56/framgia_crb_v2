class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include ApplicationHelper

  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end
  
  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  def validate_permission_change_of_calendar calendar
    unless current_user.permission_make_change?(calendar) || 
      current_user.permission_manage?(calendar)
      redirect_to root_path
    end
  end

  def validate_permission_see_detail_of_calendar calendar
    if !current_user.has_permission?(calendar) ||
      (current_user.permission_hide_details?(calendar) && !calendar.share_public?)
      redirect_to root_path
    end
  end
end
