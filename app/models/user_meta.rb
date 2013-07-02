class UserMeta < ActiveRecord::Base
  attr_accessible :user_id, :key, :value
  belongs_to :user
end
