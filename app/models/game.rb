class Game < ActiveRecord::Base
  include GameHelper
  include ApplicationHelper

  has_many :game_users
  has_many :moves
  belongs_to :user1, :class_name => "User", :foreign_key => "fst_user"
  belongs_to :user2, :class_name => "User", :foreign_key => "scd_user"

  attr_accessible :num_players, :fst_user, :scd_user, :finished, :validated, :countable

  def time
    return '60' if countable && num_players == 2
    '"no"'
  end

  def first_user
    game_users.each do |gu|
      return gu if gu.user_id == user1.id
    end
  end

  def second_user
    game_users.each do |gu|
      return gu if gu.user_id == user2.id
    end
  end

  def user_turn
    last_move = moves.last
    if last_move
      User.find( fst_user + scd_user - last_move.user_id )
    else
      user1
    end
  end

  def enemyTurn
    if first_user.user_id == user_turn.id
      second_user
    else
      first_user
    end
  end

  def user_or_guest(user)
    return user if user
    "Guest"
  end

  def winner
    unless user1 && user2
      unless user1
        return "Guest" if second_user.num_airplanes == 0
        return user2
      end

      unless user2
        return "Guest" if first_user.num_airplanes == 0
        return user1
      end
    end

    return user2 if first_user.num_airplanes == 0
    return user1 if second_user.num_airplanes == 0
    if countable
      last_move = moves.last
      if last_move
        if 59 - (Time.now - last_move.updated_at).to_i < 0
          return user1 if last_move.user_id == fst_user
          return user2 if last_move.user_id == scd_user
        end
      else
        if 59 - (Time.now - created_at).to_i < 0
          return user2
        end
      end
    end
    false
  end

  def loser
    return user1 if first_user.num_airplanes == 0
    return user2 if second_user.num_airplanes == 0
    if countable
      last_move = moves.last
      if last_move
        if 59 - (Time.now - last_move.updated_at).to_i <= 0
          return user2 if last_move.user_id == fst_user
          return user1 if last_move.user_id == scd_user
        end
      else
        if 59 - (Time.now - created_at).to_i <= 0
          return user1
        end
      end
    end
   false
  end

  def enemy
    User.find( fst_user + scd_user - user_turn.id)
  end

  def enemyMap
    enemy.mapFromGame(id)
  end

  def the_other(user)
    return user1 if scd_user == user.id
    return user2 if fst_user == user.id && scd_user != 0
    user
  end

  def finish_it
    broadcast_game(id.to_s, "move", "4")
    broadcast("/channel/" + user1.special_key.to_s, 
              '{"type":2, "turn": 3, "game_id":'+id.to_s+'}')
    broadcast("/channel/" + user2.special_key.to_s, 
              '{"type":2, "turn": 3, "game_id":'+id.to_s+'}')
  end
end
