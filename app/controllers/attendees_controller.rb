class AttendeesController < ApplicationController
  load_and_authorize_resource

  def destroy
    respond_to do |format|
      if @attendee.destroy
        format.js do
          flash[:sucess] = t "events.flashs.delete_attendee"
          render action: :destroy
        end
      else
        format.js
      end
    end
  end
end
