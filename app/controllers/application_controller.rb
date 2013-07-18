class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :mobile_device
  
  def mobile_device
    @mobile_device ||= request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(iPhone|iPad|iPod|BlackBerry|Android|Windows Phone 8)/]
  end

  def current_user
    super || guest_user
  end

  def guest_user
    @guest ||= User.where(:id => session[:guest_user_id]).first unless session[:guest_user_id].nil?
  end

end
