module ApplicationHelper
  require File.expand_path('../../../config/initializers/faye_token.rb', __FILE__)


  def broadcast(channel, data)
    message = {:channel => channel, :data => data, :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def user_online
    if user_signed_in?
      current_user.online
    end
  end

  def is_user_friend_with(x, y, validated)
    if Relation.where("((user_id = (?) and friend_id = (?)) or (user_id = (?) and friend_id = (?))) and validated = ?", x, y, y, x, validated).count == 1
      true
    else
      false
    end
  end

end
