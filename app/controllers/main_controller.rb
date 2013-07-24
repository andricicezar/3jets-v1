class MainController < ApplicationController
  include ApplicationHelper
  include NotificationHelper
  before_filter :authenticate_user!, :unless => :guest_user
  # before_filter :user_online

  def index
    "qqq"
  end

  def facebook_delete
    current_user.facebook_finder = !current_user.facebook_finder
    current_user.save
    render :json => 1
  end

  def facebook_friends
    if current_user.facebook_uid == '0'
      render :json => "You need to connect with a facebook account. For that you need to edit your profile."
      return
    end

    meta = UserMeta.where(:user_id => current_user.id, :key => "facebook_token").first
    user = FbGraph::User.me(meta.value)
    s = []
    user.friends.each do |friend|
      s.push friend.raw_attributes[:id].to_s
    end

    friends = User.where("facebook_uid in (?)", s)

    no = 0
    friends.each do |friend|
      rel = Relation.where("((user_id = :x and friend_id = :y) or (user_id = :y and friend_id = :x))", {:x => current_user.id, :y => friend.id}).first
      if rel
        unless rel.validated
          ++no
          rel.validated = true
          rel.save
        end
      else
        ++no
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
      format.json { render :json => "You have #{no} new friends!" }
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
    @users = User.veterans.order('elo DESC').offset((id-1)*7).limit(8)

    if @users.length == 8
      @next = id+1
      @users.pop
    end
  end

  def tutorial
  end

  def credits
  end
  
  def settings
  end


  def search_users
    prefix = params[:term] + "%"
    render json: User.where("(lower(nickname) like lower(?)) or (lower(email) like lower(?))", prefix, prefix)
                     .limit(10), root: false
  end

  def search_friends
    prefix = params[:term] + "%"
    rel = Relation.where("(user_id=?)or(friend_id=?)", current_user.id, current_user.id)
    aux = []
    rel.each do |r|
      aux.push r.user_id if r.user_id != current_user.id
      aux.push r.friend_id if r.friend_id != current_user.id
    end
    render json: User.where("id in (?) and lower(nickname) like lower(?)", aux, prefix).limit(10), root: false
  end

end
