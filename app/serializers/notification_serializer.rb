class NotificationSerializer < ActiveModel::Serializer
  attributes :title, :user_pic, :user_name, :user_url, :accept_url, :decline_url

  def user_pic
    User.find(object.user_id).image_url
  end

  def user_url
    user_profile_url(object.user_id)
  end

  def user_name
    User.find(object.user_id).name
  end
end
