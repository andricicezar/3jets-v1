class Relation < ActiveRecord::Base
  attr_accessible :user_id, :friend_id
  belongs_to :user, :class_name => "User"
  belongs_to :friend, :class_name => "User"
end
