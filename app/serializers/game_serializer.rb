class GameSerializer < ActiveModel::Serializer
  attributes :game_id, :game_ur, :num_players, :enemy_name, :enemy_pic, :turn, :time

  def turn
    if Airplane.where(:game_id => object.id, :user_id => current_user.id).count == 0
      return 2
    end
    if object.user_turn.id == current_user.id
      return 1
    end
    0
  end

  def game_id
    object.id
  end

  def game_ur
    game_url(object.id)
  end

  def enemy_name
    return current_user.name if !object.user2
    if object.user1.id == current_user.id
      object.user2.name
    else
      object.user1.name
    end
  end

  def enemy_pic
    return current_user.image_url if !object.user2
    if object.user1.id == current_user.id
      object.user2.image_url
    else
      object.user1.image_url
    end
  end

  def time
    if object.countable
      if object.moves.last
        return 60 - (Time.now - object.moves.last.created_at).to_i
      else
        if object.num_players == 2
          if (Time.now - object.updated_at).to_i > 65
            return -1
          else
            return 60 - (Time.now - object.updated_at).to_i
          end
        end
      end
    end
    "no"
  end
end
