class CalendarsController < ApplicationController
  load_and_authorize_resource
  before_action :load_colors, except: [:show, :destroy]
  before_action :load_users, :load_permissions,  only: [:new, :edit]
  before_action only: [:edit, :update] do
    unless current_user.permission_manage? @calendar
      redirect_to root_path
    end
  end

  def index
    @my_calendars = current_user.my_calendars
    @other_calendars = current_user.other_calendars
    @manage_calendars = current_user.manage_calendars
    @event = Event.new
    @users = User.all_other_users current_user.id
  end

  def create
    @calendar.user_id = current_user.id
    if @calendar.save
      flash[:success] = t "calendar.success_create"
      redirect_to root_path
    else
      flash[:danger] = t "calendar.danger_create"
      render :new
    end
  end

  def edit
    if params[:email]
      @user_selected = User.find_by email: params[:email]
    end
  end

  def update
    @calendar.status = "no_public" unless calendar_params[:status]
    if @calendar.update_attributes calendar_params
      flash[:success] = t "calendar.success_update"
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    if @calendar.destroy
      flash[:success] = t "calendars.deleted"
    else
      flash[:danger] = t "calendars.not_deleted"
    end
    redirect_to root_path
  end

  private
  def calendar_params
    params.require(:calendar).permit Calendar::ATTRIBUTES_PARAMS
  end

  def load_colors
    @colors = Color.all
  end

  def load_users
    @users = User.all
  end

  def load_permissions
    @permissions = Permission.all
  end
end
