class MainController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  before_filter :user_online

  def index
    "qqq"
  end

  def facebook_friends
    return if current_user.facebook_uid == '0'

    meta = UserMeta.where(:user_id => current_user.id, :key => "facebook_token").first
    user = FbGraph::User.me(meta.value)

    s = []
    user.friends.each do |friend|
      s.push friend.raw_attributes[:id].to_s
    end

    friends = User.where("facebook_uid in (?)", s)
    no = 0
    friends.each do |friend|
      ++no
      rel = Relation.where("((user_id = :x and friend_id = :y) or (user_id = :x and friend_id = :y))", {:x => current_user.id, :y => friend.id}).first
      if rel
        rel.validated = true
        rel.save
      else
        Relation.create(:user_id => current_user.id,
                        :friend_id => friend.id,
                        :validated => true)
        send_friend(current_user, friend)

        notf = Notification.create(
                :notf_type => 5,
                :title => "You've a new friend!",
                :special_class => "",
                :user_id => current_user.id,
                :friend_id => friend.id,
                :accept_url => "",
                :view_url => user_profile_url(current_user.id))
        send_notf(notf, current_user, friend)
      end
    end

    respond_to do |format|
      format.html { render :json => no }
    end
  end

  def index2
    current_user.online
    respond_to do |format|
      format.json { render :json => 1}
    end
  end

  def ranking
    id = params[:id].to_i
    if id > 1
      @prev = id-1
    end
    @users = User.veterans.order('elo DESC').offset((id-1)*7).limit(7)

    if User.offset(id*7).first
      @next = id+1
    end
  end

  def search_users
    prefix = params[:term] + "_%"
    render json: User.where("(nickname like ?) or (email like ?)", prefix, prefix)
                     .limit(10), root: false
  end

end
