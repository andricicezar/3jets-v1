class UserController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!
  before_filter :user_online, :except => [:friends, :games, :notifications]

  def profile
    @user = User.find(params[:id])
  end

  def friend
    return if current_user.id == params[:id]
    respond_to do |format|
      format.json { render :json => 1 }
    end

    user = User.find(params[:id])
    Relation.where("((user_id=? and friend_id=?) or (user_id=? and friend_id=?) ) and validated = true", current_user.id, user.id, user.id, current_user.id).each do |x|
      x.destroy
      return
    end

    x = Relation.where(:user_id => user.id, :friend_id => current_user.id).first
    if x
      # valideaza prietenie
    x.validated = true

    broadcast("/channel/" + current_user.special_key.to_s,
              '{"type": 1,
                "time": 10,
                "img": "'+user.image_url+'",
                "name": "'+user.name+'",
                "id": '+user.id.to_s+',
                "url": "/user/'+user.id.to_s+'",
                "invite": "/user/'+user.id.to_s+'/invite"}')
    broadcast("/channel/" + user.special_key.to_s,
              '{"type": 1,
                "time": 10,
                "img": "'+current_user.image_url+'",
                "name": "'+current_user.name+'",
                "id" : '+current_user.id.to_s+',
                "url": "/user/'+current_user.id.to_s+'",
                "invite": "/user/'+current_user.id.to_s+'/invite"}')
      Notification.where(:title => "Friend Request", :user_id => user.id, :friend_id => current_user.id).each do |y|
        y.destroy
      end
      x.save
      return
    end

    x = Relation.where(:user_id => current_user.id, :friend_id => user.id).first
    if x
      # distruge request
      Notification.where(:title => "Friend Request", :user_id => current_user.id, :friend_id => user.id).each do |y|
        y.destroy
      end
      x.destroy
      return
    end

    # creeaza request
    Relation.create(:user_id => current_user.id, :friend_id => user.id)
    notif = Notification.create(:notf_type => 1,
                                :title => "Friend Request",
                                :special_class => "",
                                :user_id => current_user.id,
                                :friend_id => user.id,
                                :accept_url => be_friend_with_user_url(current_user.id),
                                :view_url => user_profile_url(current_user.id))
    # trimite request prin faye
    broadcast("/channel/" + User.find(user.id).special_key.to_s,
          '{"type":3,
            "notf_type": '+notif.notf_type.to_s+', 
            "title": "'+notif.title+'", 
            "special_class": "'+notif.special_class+'",
            "accept_url":"'+notif.accept_url+'",
            "view_url":"'+notif.view_url+'",
            "decline_url":"'+destroy_notification_url(notif.id)+'",
            "user_url": "'+user_profile_url(current_user.id)+'",
            "user_pic": "'+current_user.image_url+'",
            "user_name": "'+current_user.name+'"}')
  end

  def invite
    if current_user.id == params[:id] || !is_user_friend_with(current_user.id, params[:id], true)
       redirect_to home_path
       return
    end
    if Notification.where(:user_id => current_user.id, :friend_id => params[:id], :title => "Game Request").count > 0   
      x = Game.where(:fst_user => current_user.id, :scd_user => params[:id], :countable => false, :finished => false).last
      redirect_to game_path(x.id)
      return
    end
    game = Game.create(:fst_user => current_user.id,
                       :scd_user => params[:id],
                       :validated => false,
                       :countable => false)
    notif = Notification.create(
              :notf_type => 2,
              :title => "Game Request",
              :special_class => "",
              :user_id => current_user.id,
              :friend_id => params[:id],
              :accept_url => game_validate_url(game.id),
              :view_url => user_profile_url(current_user.id))
    broadcast("/channel/" + User.find(params[:id]).special_key.to_s,
          '{"type":3, 
            "notf_type": '+notif.notf_type.to_s+',
            "title": "'+notif.title+'", 
            "special_class": "'+notif.special_class+'",
            "accept_url":"'+notif.accept_url+'",
            "view_url":"'+notif.view_url+'",
            "decline_url":"'+destroy_notification_url(notif.id)+'",
            "user_url": "'+user_profile_url(current_user.id)+'",
            "user_pic": "'+current_user.image_url+'",
            "user_name": "'+current_user.name+'"}')
    redirect_to game_path(game.id)
  end

  def friends
    User.unscoped do
      respond_to do |format|
        format.json { render :json => Relation.where("(user_id = ? or friend_id = ?) AND validated = true", current_user.id, current_user.id).includes(:user)
                                          .includes(:friend), root: false }
      end
    end
  end

  def games
    User.unscoped do
      respond_to do |format|
        format.json { render :json => Game.where("(fst_user = (?) or scd_user = (?)) and finished = false and validated = true", current_user.id, current_user.id)
                                          .includes(:user1).includes(:user2).includes(:moves), root: false }
      end
    end
  end
  def notifications
    respond_to do |format|
      format.json { render :json => Notification.where("friend_id = ?", current_user.id), root: false }
    end
  end

  def position
    x = User.veterans.order("elo DESC").index(User.find(params[:id]))
    return redirect_to ranking_path(1) + "?message=5games" if !x
    redirect_to ranking_path(x/7+1) + "?user=" + params[:id].to_s
  end

end
