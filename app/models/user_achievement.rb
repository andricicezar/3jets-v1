class UserAchievement < ActiveRecord::Base
  attr_accessible :user_id, :achievement_id
  belongs_to :achievement
end
