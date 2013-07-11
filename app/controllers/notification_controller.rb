class NotificationController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!, :unless => :guest_user
  before_filter :user_online

  def destroy
    notif = Notification.find(params[:id])
    if (notif.user_id == current_user.id || notif.friend_id == current_user.id)
      notif.destroy
    end

    respond_to do |format|
      format.json { render :json => 1 }
    end
  end

end
