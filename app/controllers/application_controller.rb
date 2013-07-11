class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    super || guest_user
  end

  def guest_user
    @guest ||= User.find(session[:guest_user_id]) unless session[:guest_user_id].nil?
  end

end
