class Achievement < ActiveRecord::Base
  attr_accessible :name, :description, :icon, :key_watched, :min_value, :award_points, :award_icon
  has_many :user_achievements
end
