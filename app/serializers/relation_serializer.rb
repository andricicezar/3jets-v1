class RelationSerializer < ActiveModel::Serializer
  attributes :id, :url, :img, :name, :elo, :time, :invite, :label


  def invite
    invite_user_url(asdf.id)
  end

  def label
    name
  end

  def asdf
    if object.friend.id == current_user.id
      object.user
    else
      object.friend
    end
  end

  def id
    asdf.id
  end

  def elo
  end

  def img
    asdf.image_url
  end

  def url
    user_profile_url(asdf)
  end

  def name
    asdf.name
  end

  def time
    (8 - (Time.now.to_i - asdf.last_sign_in_at.to_i)/5).to_i 
  end
end
