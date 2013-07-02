class Notification < ActiveRecord::Base
  attr_accessible :notf_type, :title, :special_class, :user_id, :friend_id, :accept_url, :view_url
end
