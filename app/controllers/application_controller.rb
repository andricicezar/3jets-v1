class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :mobile_device
  
  def mobile_device
    @mobile_device = false
    if request.user_agent =~ /Mobile|webOS/
      @mobile_device = true
    end
  end

  def current_user
    super || guest_user
  end

  def guest_user
    @guest ||= User.find(session[:guest_user_id]) unless session[:guest_user_id].nil?
  end

end
