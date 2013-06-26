class Move < ActiveRecord::Base
  attr_accessible :user_id, :game_id, :top, :left, :hit
  belongs_to :game
end
