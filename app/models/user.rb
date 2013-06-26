class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  
  include ApplicationHelper

  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  attr_accessible :nickname, :elo, :email, :password, :password_confirmation, :remember_me, :deleted, :created_at, :last_sign_in_at

  has_many :relations
  has_many :game_users
  has_many :games
  default_scope where(:deleted => false)

  def soft_delete
    update_attribute(:deleted, true)
  end

  def image_url
    require 'digest/md5'
    hash = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{hash}"
  end

  def name
    if nickname.to_s.length > 5
      nickname
    else
      email_splited
    end
  end

  def email_splited
    email.split('@')[0]
  end

  def mapFromGame(game_id)
    s = ""
    Airplane.where(:user_id => id, :game_id => game_id).each do |avion|
      s += avion.shape.to_s + avion.top.to_s + avion.left.to_s + avion.rotation.to_s
    end
    s
  end

  def concatMovesVS(game, user)
    s = ""
    Move.where(:game_id => game, :user_id => user).each do |move|
      s += move.top.to_s + move.left.to_s + move.hit.to_s
    end
    s
  end

  def wins
    Result.where(:user_id => id, :result => 1).count
  end

  def losses
    Result.where(:user_id => id, :result => 0).count
  end

  def ratio
    (wins+1)/(losses+1)
  end

  def online
    update_attribute(:last_sign_in_at, Time.now)
    User.unscoped do
      Relation.where(:friend_id => id, :validated => true).includes(:user).each do |val|
        user = val.user
        if (Time.now.to_i - user.last_sign_in_at.to_i).to_i < 300
          broadcast("/channel/" + user.special_key.to_s, 
                    '{"type":1, "name" : "'+name+'", "id" : '+id.to_s+', "url": "/user/'+id.to_s+'", "invite":"/user/'+id.to_s+'/invite"}' )
        end
      end
      Relation.where(:user_id => id, :validated => true).includes(:friend).each do |val|
        user = val.friend
        if (Time.now.to_i - user.last_sign_in_at.to_i).to_i < 300
          broadcast("/channel/" + user.special_key.to_s, 
                    '{"type":1, "name" : "'+name+'", "id" : '+id.to_s+', "url": "/user/'+id.to_s+'", "invite":"/user/'+id.to_s+'/invite"}' )
        end
      end
    end
  end

  def special_key
    id * 10000000000 + created_at.to_i
  end
end
