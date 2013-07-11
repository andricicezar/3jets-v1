module GameHelper
  include NotificationHelper

  require File.expand_path('../../../config/initializers/faye_token.rb', __FILE__)

  def broadcast_game(game, channel, data)
    message = {:channel => "/game/"+game+"/"+channel, :data => data, :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  # GAME
  #
  def create_map(conf, ok = false)
    harta = []
    for i in 0..9 do
      harta[i] = []
      for j in 0..9 do
        harta[i][j] = 0
      end
    end

    harta = add_airplane(harta, conf[0].to_i, conf[1].to_i, conf[2].to_i, conf[3].to_i, ok)
    harta = add_airplane(harta, conf[4].to_i, conf[5].to_i, conf[6].to_i, conf[7].to_i, ok)
    harta = add_airplane(harta, conf[8].to_i, conf[9].to_i, conf[10].to_i, conf[11].to_i, ok)

    harta
  end

  def add_airplane(harta, type, top, left, rotation, ok = false)
    conf = {
      :top =>  [3, 0, 0, 0, 1, 2, 2, 2, 2, 2],
      :left => [2, 1, 2, 3, 2, 0, 1, 2, 3, 4]}
    (rotation-1).times do
      conf = rotate_airplane(conf)
    end

    for i in 0..9 do
      harta[ conf[:top][i] + top ][ conf[:left][i] + left ] += 1
    end

    if ok
      harta[ conf[:top][0] + top ][ conf[:left][0] + left ] += 1
    end

    harta
  end

  @current_game = nil
  def currentGame
    if !@current_game 
      if params.has_key? :game
        @current_game = Game.find(params[:game].to_i)
      elsif params.has_key? :id
        @current_game = Game.find(params[:id].to_i)
      end
    end
    @current_game
  end

  def rotate_airplane(conf)
    max = 0
    for i in 0..9 do
      max = (max < conf[:top][i])?conf[:top][i]:max
    end

    for i in 0..9 do
      aux = conf[:top][i]
      conf[:top][i] = conf[:left][i]
      conf[:left][i] = max - aux 
    end
    conf
  end

  def check_achievement(user_id, key, value)
    Achievement.where(:key_watched => key).each do |achievement|
      if achievement.min_value.to_i <= value.to_i
        unless UserAchievement.where(:achievement_id => achievement.id, :user_id => user_id).first
          UserAchievement.create(:achievement_id => achievement.id, :user_id => user_id)
          notif = Notification.create(
                    :notf_type => 4,
                    :title => achievement.name,
                    :special_class => achievement.icon,
                    :user_id => current_user.id,
                    :friend_id => current_user.id,
                    :accept_url => "",
                    :view_url => "")
          send_achievement(current_user, notif, achievement)
        end
      end
    end
  end

  def increase_value(user_id, name, need_to_reset)
    meta = UserMeta.where(:user_id => user_id, :key => name).first
    unless meta
      meta = UserMeta.create(:user_id => user_id, :key => name, :value => '0')
    end

    if need_to_reset
      meta.value = '0'
    else
      meta.value = (meta.value.to_i + 1).to_s
    end
    meta.save
    check_achievement(user_id, meta.key, meta.value)
  end

  def increase_values(user, map)
    user.user_metas.each do |meta|
      if map.has_key? (meta.key.to_sym)
        if map[meta.key.to_sym] == -1
          meta.value = '0'
        else
          meta.value = (meta.value.to_i + 1).to_s
        end
        map[meta.key.to_sym] = 2
        meta.save
        check_achievement(user.id, meta.key, meta.value)
      end
    end

    map.each do |k, v|
      if v == 1
        UserMeta.create(:user_id => user.id, :key => k.to_s, :value => '1')
        check_achievement(user.id, k.to_s, 1)
      end
    end
  end

  # FILTERS
  def is_game_finished
    if currentGame.finished
      redirect_to home_path + "?ahah"
      return
    end
  end

  def is_in_the_game
    return if !currentGame
    if currentGame.fst_user != current_user.id && currentGame.scd_user != current_user.id && currentGame.scd_user != 0
      redirect_to play_path
      false
      return
    end
    true
  end

end
