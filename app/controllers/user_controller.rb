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
    x = Relation.where("((user_id=? and friend_id=?) or (user_id=? and friend_id=?) ) and validated = true", current_user.id, user.id, user.id, current_user.id).first
    if x
      # distruge prietenie
      x.destroy
      return
    end
    
    x = Relation.where(:user_id => user.id, :friend_id => current_user.id).first
    if x
      # valideaza prietenie
      x.validated = true
      y = Notification.where(:title => "Friend Request", :user_id => user.id, :friend_id => current_user.id).first
      if y
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
    x = Notification.create(
      :title => "Friend Request",
      :user_id => current_user.id,
      :friend_id => user.id,
      :accept_url => be_friend_with_user_url(current_user.id))
    x.decline_url = destroy_notification_url(x.id)
    x.save
    broadcast("/channel/" + User.find(user.id).special_key.to_s,
          '{"type":3, 
            "title": "Friend Request", 
            "accept_url":"'+be_friend_with_user_url(current_user.id)+'",
            "decline_url":"'+destroy_notification_url(x.id)+'",
            "user_url": "'+user_profile_url(current_user.id)+'",
            "user_pic": "'+current_user.image_url+'",
            "user_name": "'+current_user.name+'"}')


  end

  def invite
    if current_user.id == params[:id] || !is_user_friend_with(current_user.id, params[:id], true) || Notification.where(:user_id => current_user.id, :friend_id => params[:id], :title => "Game Request").count > 0 then
       redirect_to home_path
       return
    end
    game = Game.create(:fst_user => current_user.id,
                       :scd_user => params[:id],
                       :validated => false,
                       :countable => false)
    notif = Notification.create(:title => "Game Request",
                               :user_id => current_user.id,
                               :friend_id => params[:id],
                               :accept_url => game_validate_url(game.id))
    notif.decline_url = destroy_notification_url(notif.id)
    notif.save
    broadcast("/channel/" + User.find(params[:id]).special_key.to_s,
          '{"type":3, 
            "title": "Game Request", 
            "accept_url":"'+game_validate_url(game.id)+'",
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
    x = User.order("elo DESC").index(User.find(params[:id]))
    redirect_to ranking_path(x/7+1)
  end

end
