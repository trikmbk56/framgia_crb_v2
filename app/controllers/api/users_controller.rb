class Api::UsersController < ApplicationController
  respond_to :json

  def update
    @user = User.find_by id: params[:id]
    if params[:status] == "UpdateUserInformation"
      render text: @user.update_attributes(user_info_params) ?
        t("user.info.update.success") : t("user.info.update.error")
    else
      if @user.update_attributes user_avatar_params
        flash[:success] = t "user.info.update.success"
      else
        flash[:danger] = t "user.info.update.error"
      end
      respond_to do |format|
        format.html{redirect_to @user}
      end
    end
  end

  private
  def user_info_params
    params.require(:user).permit :name, :email
  end

  def user_avatar_params
    params.require(:user).permit :avatar
  end
end
