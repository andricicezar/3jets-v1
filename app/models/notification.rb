class Notification < ActiveRecord::Base
  attr_accessible :title, :user_id, :friend_id, :accept_url, :decline_url
end
