class Airplane < ActiveRecord::Base
  attr_accessible :user_id, :game_id, :shape, :top, :left, :rotation
end
