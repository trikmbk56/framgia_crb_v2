class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    @events = @user.events.where("start_date >= ?", DateTime.now).
      limit Settings.users.upcoming_event
  end
end
