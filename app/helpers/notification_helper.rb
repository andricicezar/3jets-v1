module NotificationHelper
  include ApplicationHelper


  def send_friend(sender, receiver)
    broadcast("/channel/" + receiver.special_key.to_s,
              '{"type":              1,
                "time":              10,
                "img": "'          + sender.image_url + '",
                "name": "'         + sender.name + '",
                "id": '            + sender.id.to_s + ',
                "url": "/user/'    + sender.id.to_s + '",
                "invite": "/user/' + sender.id.to_s + '/invite"}')
  end

  def send_game(game, turn, sender, receiver)
    broadcast("/channel/" + receiver.special_key.to_s,
            '{"type":           2, 
              "turn": '       + turn.to_s + ', 
              "game_id":'     + game.id.to_s + ',
              "game_ur":"'    + game_url( game.id ) + '",
              "num_players":' + game.num_players.to_s + ',
              "enemy_pic": "' + sender.image_url + '",
              "enemy_name": "'+ sender.name + '",
              "time": '       + game.time + '}')
  end

  def send_destroy_game(user, game)
    broadcast("/channel/" + user.special_key.to_s, 
              '{"type":       2, 
                "turn":       3, 
                "game_id":' + game.id.to_s + '}')
  end

  def send_notf(notf, sender, receiver)
    broadcast("/channel/" + receiver.special_key.to_s,
              '{"type":               3,
                "notf_id":'         + notf.id.to_s + ', 
                "notf_type":'       + notf.notf_type.to_s + ',
                "title": "'         + notf.title + '", 
                "special_class": "' + notf.special_class + '",
                "accept_url":"'     + notf.accept_url + '",
                "view_url":"'       + notf.view_url + '",
                "decline_url":"'    + destroy_notification_url(notf.id) + '",
                "user_url": "'      + user_profile_url(sender.id) + '",
                "user_pic": "'      + sender.image_url + '",
                "user_name": "'     + sender.name + '"}')
  end

  def send_destroy_notf(user, notf)
    broadcast("/channel/" + user.special_key.to_s,
              '{"type":       3,
                "notf_id": ' + notf.id.to_s + '}')
  end

  def send_achievement(user, notf, achievement)
    broadcast("/channel/" + user.special_key.to_s,
              '{"type":              3,
                "notf_id":'        + notf.id.to_s + ', 
                "notf_type":'      + notf.notf_type.to_s + ',
                "title":"'         + achievement.name + '", 
                "special_class":"' + notf.special_class + '",
                "accept_url":"'    + notf.accept_url + '",
                "view_url":"'      + notf.view_url + '",
                "decline_url":"'   + destroy_notification_url(notf.id) + '"}')
  end


end
