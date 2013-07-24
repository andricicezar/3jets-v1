class User < ActiveRecord::Base
  include ApplicationHelper

  devise :database_authenticatable, :registerable, :omniauthable, :trackable,
         :rememberable, :validatable, :authentication_keys => [:login]

  attr_accessible :nickname, :elo, :email, :password, :password_confirmation,
                  :veteran, :remember_me, :deleted, :last_sign_in_at, :login,
                  :twitter_uid, :facebook_uid, :google_uid, :image_link, :is_guest,
                  :facebook_finder, :is_ai
  attr_accessor :login

  has_many :relations
  has_many :game_users
  has_many :games
  has_many :user_metas

  validates_uniqueness_of :nickname, :case_sensitive => false
  validates_length_of     :nickname, :maximum => 20, :minimum => 5
  validates_uniqueness_of :email, :allow_blank => true, :allow_nil => true
  validates_uniqueness_of :twitter_uid, :unless => Proc.new { |user| user.twitter_uid == '0' }
  validates_uniqueness_of :facebook_uid, :unless => Proc.new { |user| user.facebook_uid == '0' }
  validates_uniqueness_of :google_uid, :unless => Proc.new { |user| user.google_uid == '0' }

  default_scope where(:deleted => false)
  scope :veterans, where(:veteran => true)

  def soft_delete
    update_attribute(:deleted, true)
  end

  def image_url
    return image_link if image_link.length > 5
    return gravatar_url if email.length > 5
    return "/assets/icons/default.png"
  end

  def gravatar_url
    require 'digest/md5'
    hash = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{hash}"
  end

  def name
    if nickname
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

  def online
    update_attribute(:last_sign_in_at, Time.now)
    User.unscoped do
      Relation.where(:friend_id => id, :validated => true).includes(:user).each do |val|
        user = val.user
        next unless user
        if (Time.now.to_i - user.last_sign_in_at.to_i).to_i < 300
          broadcast("/channel/" + user.special_key.to_s, 
                    '{"type":1, 
                      "time": 10,
                      "img": "'+image_url+'",
                      "name" : "'+name+'", 
                      "id" : '+id.to_s+', 
                      "url": "/user/'+id.to_s+'", 
                      "invite":"/user/'+id.to_s+'/invite"}' )
        end
      end
      Relation.where(:user_id => id, :validated => true).includes(:friend).each do |val|
        user = val.friend
        next unless user
        if (Time.now.to_i - user.last_sign_in_at.to_i).to_i < 300
          broadcast("/channel/" + user.special_key.to_s, 
                    '{"type":1, 
                      "time": 10,
                      "img": "'+image_url+'",
                      "name" : "'+name+'", 
                      "id" : '+id.to_s+', 
                      "url": "/user/'+id.to_s+'", 
                      "invite":"/user/'+id.to_s+'/invite"}' )
        end
      end
    end
  end

  def special_key
    id * 10000000000 + created_at.to_i
  end

  # OMNIAUTH
  def self.from_omniauth(auth)
    provider_col = auth.provider + "_uid"

    if auth.info.email
      if user = where(:email => auth.info.email).first
        user[provider_col] = auth.uid
        user.save
        return user
      end
    end

    where(provider_col => auth.uid).first_or_create do |user|
      user.nickname = auth.info.nickname || auth.info.name
      user.email = auth.info.email || ""
      user[provider_col] = auth.uid
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  # DEVISE
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(nickname) = :value OR lower(email) = :value", { :value => login }]).first
    else
      where(conditions).first
    end
  end

  def password_required?
    super && twitter_uid == '0' && facebook_uid == '0' && google_uid == '0'
  end

  def email_required?
    super && twitter_uid.blank? && facebook_uid.blank? && google_uid.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

end
