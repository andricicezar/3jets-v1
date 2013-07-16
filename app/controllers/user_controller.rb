class UserController < ApplicationController
  include ApplicationHelper
  include NotificationHelper
  before_filter :authenticate_user!, :unless => :guest_user
  before_filter :user_online, :only => [:angular_info, :friends, :games, :notifications]

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
      send_friend(current_user, user)
      send_friend(user, current_user)

      Notification.where(:title => "Friend Request", :user_id => user.id, :friend_id => current_user.id).each do |notf|
        send_destroy_notf(current_user, notf)
        notf.destroy
      end

      x.save
      return
    end

    x = Relation.where(:user_id => current_user.id, :friend_id => user.id).first
    if x
      # distruge request
      Notification.where(:title => "Friend Request", :user_id => current_user.id, :friend_id => user.id).each do |notf|
        send_destroy_notf(current_user, notf)
        notf.destroy
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
    send_notf(notif, current_user, user)
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
    send_notf(notif, current_user, User.find(params[:id]))
    redirect_to game_path(game.id)
  end
  
  def angular_info
    info = []
    User.unscoped do
      info = [
        Relation.where("(user_id = ? or friend_id = ?) AND validated = true", current_user.id, current_user.id).includes(:user)
                                            .includes(:friend),
        Game.where("(fst_user = (?) or scd_user = (?)) and finished = false and validated = true", current_user.id, current_user.id)
                                            .includes(:user1).includes(:user2).includes(:moves),
        Notification.where("friend_id = ?", current_user.id)
      ]
    end

    respond_to do |format|
      format.json { render :json => info, root: false }
    end
  end

  # DEPRECATED
  def friends
    User.unscoped do
      respond_to do |format|
        format.json { render :json => Relation.where("(user_id = ? or friend_id = ?) AND validated = true", current_user.id, current_user.id).includes(:user)
                                          .includes(:friend), root: false }
      end
    end
  end

  # DEPRECATED
  def games
    User.unscoped do
      respond_to do |format|
        format.json { render :json => Game.where("(fst_user = (?) or scd_user = (?)) and finished = false and validated = true", current_user.id, current_user.id)
                                          .includes(:user1).includes(:user2).includes(:moves), root: false }
      end
    end
  end

  # DEPRECATED
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
