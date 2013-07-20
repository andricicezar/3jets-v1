module ActiveAdmin::ViewsHelper
  def mapFromGame(user_id, game_id)
    s = ""
    Airplane.where(:user_id => user_id, :game_id => game_id).each do |avion|
      s += avion.shape.to_s + avion.top.to_s + avion.left.to_s + avion.rotation.to_s
    end
    s
  end

  def concatMovesVS(game_id, user_id)
    s = ""
    Move.where(:game_id => game_id, :user_id => user_id).each do |move|
      s += move.top.to_s + move.left.to_s + move.hit.to_s
    end
    s
  end
end

