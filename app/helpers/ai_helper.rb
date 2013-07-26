module AiHelper
  include VlaicuHelper
  def copyMap(x, y)
    for i in 0..9
      x[i] = y[i].dup
    end
  end
  def createConf
    conf = ""
    # cream hartile
    harta = []
    auxHarta = []
    for i in 0..9 do
      harta[i] = []
      auxHarta[i] = []
      for j in 0..9 do
        harta[i][j] = 0
        auxHarta[i][j] = 0
      end
    end

    # adaugam 3 avioane
    2.times do
      # pana gasim un avion bun
      while true
        copyMap(auxHarta, harta)

        # calculam pozitiile
        top = Random.rand(5)
        left = Random.rand(5)
        rotation = 1 + Random.rand(3)
        add_airplane(auxHarta, 1, top, left, rotation, false)

        # verificam daca avionul nu se suprapune
        next unless check_map(auxHarta)
        # daca nu se suprapune, salvam si iesim
        conf += "1" + top.to_s + left.to_s + rotation.to_s
        copyMap(harta, auxHarta)
        break
      end
    end

    ok = false
    for i in 1..5 do
      for j in 1..5 do
        if harta[i][j] == 0
          for r in 1..4 do
            copyMap(auxHarta, harta)
            add_airplane(auxHarta, 1, i, j, r, false)
            next unless check_map(auxHarta)
            ok = true
            conf += "1" + i.to_s + j.to_s + r.to_s
            copyMap(harta, auxHarta)
            break
          end
        end
        break if ok
      end
      break if ok
    end

    unless ok
      puts conf
      for j in 0..5 do
        copyMap(auxHarta, harta)
        add_airplane(auxHarta, 1, 6, j, 1, false)
        next unless check_map(auxHarta)
        ok = true
        conf += "16" + j.to_s + "1"
        copyMap(harta, auxHarta)
        break
      end
    end
    unless ok
      puts conf
      for j in 0..5 do
        copyMap(auxHarta, harta)
        add_airplane(auxHarta, 1, 6, j, 3, false)
        next unless check_map(auxHarta)
        ok = true
        conf += "16" + j.to_s + "3"
        copyMap(harta, auxHarta)
        break
      end
    end

    unless ok
      puts conf
      for i in 0..5 do
        copyMap(auxHarta, harta)
        add_airplane(auxHarta, 1, i, 6, 4, false)
        next unless check_map(auxHarta)
        ok = true
        conf += "1" + i.to_s + "64"
        copyMap(harta, auxHarta)
        break
      end
    end
    unless ok
      puts conf
      for i in 0..5 do
        copyMap(auxHarta, harta)
        add_airplane(auxHarta, 1, i, 6, 2, false)
        next unless check_map(auxHarta)
        ok = true
        conf += "1" + i.to_s + "62"
        copyMap(harta, auxHarta)
        break
      end
    end
    return conf
  end

  def ai_turn(id, game)
    if (id == 4)
      AiWorker.perform_async(current_user.id, id, game.id)
      #ai1_aiMove4(current_user.id, id, game)
    end
  end

  def finish_ai(user_id, game, lastMove)
    current_user = User.find(user_id)
    enemyMap = create_map(game.enemyMap, true)
    message = enemyMap[ lastMove[0] ][ lastMove[1] ]

    if message == 2
      aux = game.enemyTurn
      aux.num_airplanes -= 1
      aux.save
    end


    Move.create(:user_id => game.user2.id,
                :game_id => game.id,
                :top => lastMove[0],
                :left => lastMove[1],
                :hit => message)
    data = game.user2.id.to_s + lastMove[0].to_s + lastMove[1].to_s + message.to_s
    broadcast_game(game.id.to_s, "move", data)
    send_game(game, 1, game.user2, current_user)
    game.finish_it if game.winner
  end


end
