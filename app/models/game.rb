class Game < ActiveRecord::Base
  has_many :game_users
  has_many :moves
  belongs_to :user1, :class_name => "User", :foreign_key => "fst_user"
  belongs_to :user2, :class_name => "User", :foreign_key => "scd_user"

  attr_accessible :num_players, :fst_user, :scd_user, :finished, :validated, :countable

  def first_user
    game_users.first
  end

  def second_user
    game_users.last
  end

  def user_turn
    last_move = moves.last
    if last_move
      if (last_move.hit > 0)
        User.find( last_move.user_id )
      else
        User.find( fst_user + scd_user - last_move.user_id )
      end
    else
      User.find( fst_user )
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
    return 0 if finished == false
    if first_user.num_airplanes == 0
      second_user.user_id
    else
      if second_user.num_airplanes == 0
        first_user.user_id
      else
        0
      end
    end
  end

  def enemy
    User.find( fst_user + scd_user - user_turn.id)
  end

  def enemyMap
    enemy.mapFromGame(id)
  end
end
