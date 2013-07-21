class UserSerializer < ActiveModel::Serializer
  include ApplicationHelper
  attributes :label, :profile_url, :game_invite, :online, :position_url, :veteran

  def label
    object.name
  end

  def profile_url
    user_profile_url(object.id)
  end

  def position_url
    user_position_url(object.id)
  end
  
  def game_invite
    invite_user_url(object.id)
  end

  def online
    return false unless is_user_friend_with(object.id, current_user.id, true)
    return true if Time.now - object.last_sign_in_at < 30
    false
  end
end
