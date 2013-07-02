class Game < ActiveRecord::Base
  include GameHelper
  include ApplicationHelper


  has_many :game_users
  has_many :moves
  belongs_to :user1, :class_name => "User", :foreign_key => "fst_user"
  belongs_to :user2, :class_name => "User", :foreign_key => "scd_user"

  attr_accessible :num_players, :fst_user, :scd_user, :finished, :validated, :countable

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

  def winner
    return user2 if first_user.num_airplanes == 0
    return user1 if second_user.num_airplanes == 0
    false
  end

  def loser
    return user1 if first_user.num_airplanes == 0
    return user2 if second_user.num_airplanes == 0
    false
  end

  def enemy
    User.find( fst_user + scd_user - user_turn.id)
  end

  def enemyMap
    enemy.mapFromGame(id)
  end

  def finish_it
    broadcast_game(id.to_s, "move", "4")
    broadcast("/channel/" + user1.special_key.to_s, 
              '{"type":2, "turn": 3, "game_id":'+id.to_s+'}')
    broadcast("/channel/" + user2.special_key.to_s, 
              '{"type":2, "turn": 3, "game_id":'+id.to_s+'}')
  end
end
