class UserSerializer < ActiveModel::Serializer
  attributes :label, :profile_url, :position_url, :veteran

  def label
    object.name
  end

  def profile_url
    user_profile_url(object.id)
  end

  def position_url
    user_position_url(object.id)
  end
end
