class GameController < ApplicationController
  include GameHelper
  include ApplicationHelper

  before_filter :authenticate_user!
  before_filter :user_online
  before_filter :is_game_finished, :only => [:validatem, :exit, :play, :wait, :adduser]
  before_filter :is_in_the_game, :only => [:init, :validatedm, :exit, :play, :wait, :adduser, :asdf]

  def init
    if params.has_key? :game
      if currentGame.fst_user == current_user.id
        @opponent = currentGame.user2
      else
        @opponent = currentGame.user1
      end
    end
  end

  def validatedm
    if currentGame.scd_user == current_user.id
      currentGame.validated = true
      currentGame.save

      Notification.where(:title => "Game Request", :user_id => currentGame.fst_user, :friend_id => currentGame.scd_user).each do |notif|
        notif.destroy
      end
      qasw = currentGame.user1
      broadcast("/channel/" + current_user.special_key.to_s,
                '{"type":2, "turn":2, 
                "game_id":'+currentGame.id.to_s+',
                "game_ur":"'+game_url(currentGame.id)+'",
                "num_players":'+currentGame.num_players.to_s+',
                "enemy_pic": "'+qasw.image_url+'",
                "enemy_name": "'+qasw.name+'",
                "time": "no"}')
      v = 2
      v = 1 if Airplane.where(:game_id => currentGame.id, :user_id => qasw.id).count > 0
      broadcast("/channel/" + qasw.special_key.to_s,
                '{"type":2, "turn":'+v.to_s+', 
                "game_id":'+currentGame.id.to_s+',
                "game_ur":"'+game_url(currentGame.id)+'",
                "num_players":'+currentGame.num_players.to_s+',
                "enemy_pic": "'+current_user.image_url+'",
                "enemy_name": "'+current_user.name+'",
                "time": "no"}')

    end
    respond_to do |format|
      format.json { render :json => 1 }
    end
  end
    
  def finish
    @winner = currentGame.winner
    @loser = currentGame.loser
    if !@winner
      redirect_to game_wait_url(params[:id])
      return
    end

    if !currentGame.finished
      currentGame.finished = true
      currentGame.save

      if @loser.id == currentGame.fst_user
        v = currentGame.first_user
        v.num_airplanes = 0
        v.save
      else
        v = currentGame.second_user
        v.num_airplanes = 0
        v.save
      end

      notif = Notification.create(
                :notf_type => 3,
                :title => "You've lost!",
                :special_class => "",
                :user_id => @winner.id,
                :friend_id => @loser.id,
                :accept_url => "",
                :view_url => game_victory_url(currentGame.id))
      broadcast("/channel/" + @loser.special_key.to_s,
            render_notif3(notif, @winner))
      
      notif = Notification.create(
                :notf_type => 3,
                :title => "You've win!",
                :special_class => "",
                :user_id => @loser.id,
                :friend_id => @winner.id,
                :accept_url => "",
                :view_url => game_victory_url(currentGame.id))
      broadcast("/channel/" + @winner.special_key.to_s,
            render_notif3(notif, @loser))

      return if !currentGame.countable

      increase_value(@winner.id, "combo_wins", false)
      increase_value(@winner.id, "combo_losses", true)
      increase_value(@loser.id,  "combo_losses", false)
      increase_value(@loser.id, "combo_wins", true)
      increase_value(@winner.id, "alltime_wins", false)
      increase_value(@loser.id,  "alltime_losses", false)

      # ELO
      elo_constant = 32
        # elo winner
          # probability
          probability = 1.0/(  1 + 10**(  (@loser.elo - @winner.elo)/400  )  )
          # recalculate
          @winner.elo += elo_constant * (1 - probability)
        # elo loser
          # probability
          probability = 1.0/(  1 + 10**(  (@winner.elo - @loser.elo)/400  )  )
          @loser.elo += elo_constant * (0 - probability)
        # save
        @winner.save
        @loser.save

      Result.create(:user_id => @winner.id,
                    :game_id => currentGame.id,
                    :result => 1)
      Result.create(:user_id => @loser.id,
                    :game_id => currentGame.id,
                    :result => 0)
    end

    Notification.where(:view_url => game_victory_url(currentGame.id), :friend_id => current_user.id).each do |notif|
      notif.destroy
    end

    if !currentGame.user1.veteran
      if Result.where(:user_id => currentGame.user1.id).count > 5
        v = currentGame.user1
        v.veteran = true
        v.save
      end
    end

    if !currentGame.user2.veteran
      if Result.where(:user_id => currentGame.user2.id).count > 5
        v = currentGame.user2
        v.veteran = true
        v.save
      end
    end
  end

  def check
    if currentGame.winner
      currentGame.finish_it
      redirect_to game_victory_url(params[:id])
      return
    end
    respond_to do |format|
      format.json { render :json => 1 }
    end
  end

  def exit
    ok = false

    if currentGame.game_users.count < 2
      Notification.where(:accept_url => game_validate_url(currentGame.id)).each do |notf|
        notf.destroy
      end
      broadcast("/channel/" + current_user.special_key.to_s, 
                '{"type":2, "turn":3, "game_id":'+currentGame.id.to_s+'}')
      currentGame.destroy
      redirect_to home_url
      return
    end

    if currentGame.fst_user == current_user.id
      aux = currentGame.first_user
      aux.num_airplanes = 0
      aux.save
      ok = true
    else
      if currentGame.scd_user == current_user.id
        aux = currentGame.second_user
        aux.num_airplanes = 0
        aux.save
        ok = true
      end
    end

    if ok
      currentGame.finish_it
      redirect_to game_victory_url(params[:id])
      return
    end
    redirect_to play_url(params[:id])
  end

  def play
    # verific daca sunt setate avioanele
    if Airplane.where(:user_id => current_user.id, :game_id => currentGame.id).count < 3
      redirect_to play_url + "?game=" + currentGame.id.to_s
      return
    end


    # verificam daca are oponent
    if currentGame.num_players == 1
      redirect_to game_wait_url(params[:id])
      return
    end

    @curr_user = currentGame.user_turn
    @other_user = currentGame.enemy
  end

  def wait
    # in caz ca e al doilea, il anuntam pe primu ca are prieten
    if currentGame.num_players == 2
      broadcast_game(params[:id], "add_user", "succes")
      broadcast("/channel/" + currentGame.user1.special_key.to_s,
                '{"type":2, "turn":1, "game_id":'+currentGame.id.to_s+',
                "enemy_pic": "'+current_user.image_url+'",
                "enemy_name": "'+current_user.name+'"}')
     redirect_to game_url(params[:id])
    end
  end

  def adduser
    # salvez configuratia jucatorului la jocul curent
    GameUser.create(:user_id => current_user.id, :game_id => currentGame.id)
    for i in 0..2 do
      Airplane.create(:user_id => current_user.id,
                      :game_id => currentGame.id,
                      :shape => params[:conf][i*4].to_i,
                      :top => params[:conf][i*4+1].to_i,
                      :left => params[:conf][i*4+2].to_i,
                      :rotation => params[:conf][i*4+3].to_i)
    end

    # verific daca useri sunt setati dinainte
    if currentGame.scd_user == 0
      # daca nu setez
      if currentGame.num_players == 0
        currentGame.fst_user = current_user.id
      else
        currentGame.scd_user = current_user.id
      end
    end
    # adaug ca a mai intrat o persoana in joc
    currentGame.num_players += 1
    currentGame.save
    redirect_to game_wait_url(currentGame.id)
  end

  def asdf
    # verific daca e tura lui, daca nu, returnez 3
    if currentGame.user_turn.id != current_user.id
      # broadcast_game(currentGame.id.to_s, "move", "3")
      respond_to do |format|
        format.json { render :json => 3 }
      end
      return
    end

    topA = params[:top]
    leftA = params[:left]

    # verific daca nu cumva meciul e gata
    if currentGame.finished
      broadcast_game(currentGame.id.to_s, "move", "4")
      respond_to do |format|
        format.json { render :json => 4 }
      end
    end

    # verific daca nu a mai facut cumva aceeasi tura
    if Move.where(:user_id => current_user.id, :game_id => params[:id], :top => topA.to_i, :left => leftA.to_i).count == 1
      broadcast_game(currentGame.id.to_s, "move", "5")
      respond_to do |format|
        format.json { render :json => 5 }
      end
      return
    end

    # creez harta inamicului
    enemyMap = create_map(currentGame.enemyMap, true)

    # 0 - nu a nimerit 
    # 1 - a nimerit
    # 2 - a nimerit cap
    # 3 - nu e tura lui
    # 4 - a distrus toate cele 3 avioane
    # 5 - a mai lovit o data in acelasi loc

    # memorez ce a nimerit
    message = enemyMap[ topA.to_i ][ leftA.to_i ]

    # daca a nimerit cap, scad numarul de avioane ale inamicului
    if message == 2
      aux = currentGame.enemyTurn
      aux.num_airplanes -= 1
      aux.save
    end

    broadcast("/channel/" + currentGame.enemy.special_key.to_s, 
                            '{"type":2, "turn":1, "game_id":'+currentGame.id.to_s+', "time":'+(if currentGame.countable then '60' else '"no"' end)+'}')
    broadcast("/channel/" + current_user.special_key.to_s,
                            '{"type":2, "turn":0, "game_id":'+currentGame.id.to_s+', "time":'+(if currentGame.countable then '60' else '"no"' end)+'}')


    if currentGame.countable
      map = {}
      case message
      when 0
        map[:combo_heads] = -1
        map[:combo_hits] = -1
        map[:combo_heads_hits] = -1

        map[:combo_miss] = 1
        map[:alltime_miss] = 1

        increase_value(currentGame.enemy.id, "combo_heads_taken", true)
      when 1
        map[:combo_miss] = -1
        map[:combo_heads] = -1

        map[:combo_hits] = 1
        map[:combo_heads_hits] = 1
        map[:alltime_hits] = 1
        map[:alltime_heads_hits] = 1

        increase_value(currentGame.enemy.id, "combo_heads_taken", true)
      when 2
        map[:combo_miss] = -1
        map[:combo_hits] = -1

        map[:combo_heads] = 1
        map[:combo_heads_hits] = 1
        map[:alltime_heads] = 1
        map[:alltime_heads_hits] = 1

        increase_value(currentGame.enemy.id, "combo_heads_taken", false)
      end
      increase_values(current_user, map)
    end

    # inregistrez miscarea
    # de aici incolo .enemy si .enemyTurn sunt useless
    Move.create(:user_id => current_user.id,
                :game_id => params[:id],
                :top => topA.to_i,
                :left => leftA.to_i,
                :hit => message)

    # trimit mesaj cu atacul facut
    data = current_user.id.to_s + topA + leftA + message.to_s
    broadcast_game(currentGame.id.to_s, "move", data)
    # daca inamicul nu mai are nici un avion
    # trimit mesaj ca jocul s-a terminat
    currentGame.finish_it if currentGame.winner

    respond_to do |format|
      format.json { render :json => message }
    end
  end

  def search
    games = Game.where(:num_players => 1, :countable => true)

    if games.count > 0
      games.each do |game|
        if game.fst_user != current_user.id
          redirect_to game_adduser_url(games.first.id, params[:conf])
          return
        end
      end
    end

    newGame = Game.create(:num_players => 0)
    redirect_to game_adduser_url(newGame.id, params[:conf])
  end

  def match
    harta = create_map(params[:conf])
    x = ""
    if params.has_key? :game
      x = "&game=" + params[:game]
    end
    for i in 0..9 do
      for j in 0..9 do
        if harta[i][j] > 1
          redirect_to play_url + "/?error=fail" + x
	        return
        end
      end
    end
    
    if params.has_key? :game
      redirect_to game_adduser_url(params[:game].to_i, params[:conf])
      return
    end

    redirect_to search_game_url(params[:conf])
  end
end
