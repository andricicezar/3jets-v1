module AiHelper
  # include GameHelper
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
      #AiWorker.perform_async(current_user.id, id, game.id)
      aiMove4(current_user.id, id, game)
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

  def aiMove4(user_id, id, game)
    # chose move
    moves = Move.where(:game_id => game.id, :user_id => id)
    lastMove = [0, 0]
    # create map
    @map = []
    @used = []
    @heads = []
    @auxMap = []
    for i in 0..9 do
      @map << []
      for j in 0..9 do
        @map[i] << 0
      end
    end
    copyMap(@used, @map)
    copyMap(@auxMap, @map)
    copyMap(@heads, @map)

    moves.each do |move|
      @map[move.top][move.left] = move.hit.to_i + 1
    end

    if moves.length < 4
      preMoves = [[2, 2], [7,2], [2,7], [7,7]]
      lastMove = preMoves[moves.length]
      return finish_ai(user_id, game, lastMove)
    end

    @noAirplanes = 0
    @pointsUsed = 0
    search_airplane_heads

    max = 0
    for i in 0..9 do
      for j in 0..9 do
        if @heads[i][j] > max
          max = @heads[i][j]
          lastMove = [i, j]
        end
      end
    end
    if max == 0
      30.times do
        lastMove = [1+Random.rand(8), 1+Random.rand(8)]
        break if @map[lastMove[0]][lastMove[1]] == 0
      end
    end
    return finish_ai(user_id, game, lastMove)
  end

  def search_airplane_heads
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 3 && @used[i][j] == 0
          @noAirplanes += 1
          match_airplane_head(i, j)
          @noAirplanes -= 1
          return
        end
      end
    end
    search_airplane
  end

  def match_airplane_head(x, y)
    conf = {
      :top =>  [3, 0, 0, 0, 1, 2, 2, 2, 2, 2],
      :left => [2, 1, 2, 3, 2, 0, 1, 2, 3, 4]}
    confAux = {}
    for i in 0..3 do
      conf = rotate_airplane(conf)
      confAux[:top] = conf[:top].dup
      confAux[:left] = conf[:left].dup
      for aux in 0..9 do
        confAux[:top][aux] -= conf[:top][0]
        confAux[:left][aux] -= conf[:left][0]
      end
      next unless iese_din_matrice(x, y, confAux)
      next unless suprapunere_elemente(x, y, confAux)
      marcheaza_configuratia(x, y, confAux)
      search_airplane_heads
      sterge_configuratia(x, y, confAux)
    end
  end


  def search_airplane
    return if @noAirplanes > 3
    ok = true
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 2 && @used[i][j] == 0
          @noAirplanes += 1
          match_airplane(i, j)
          @noAirplanes -= 1
          ok = false
        end
      end
    end
    return unless ok
    for i in 0..9 do
      for j in 0..9 do
        if @auxMap[i][j] == 3 && @map[i][j] == 0
          @heads[i][j] += @noAirplanes
        end
      end
    end
  end

  def match_airplane(x, y)
    conf = {
      :top =>  [3, 0, 0, 0, 1, 2, 2, 2, 2, 2],
      :left => [2, 1, 2, 3, 2, 0, 1, 2, 3, 4]}
    confAux = {}
    for i in 0..3 do
      for j in 1..9 do
        confAux[:top] = conf[:top].dup
        confAux[:left] = conf[:left].dup
        for aux in 0..9 do
          confAux[:top][aux] -= conf[:top][j]
          confAux[:left][aux] -= conf[:left][j]
        end

        next unless iese_din_matrice(x, y, confAux)
        next unless suprapunere_elemente(x, y, confAux)
        marcheaza_configuratia(x, y, confAux)
        search_airplane
        sterge_configuratia(x, y, confAux)
      end

      conf = rotate_airplane(conf)
    end

  end

  def iese_din_matrice(x, y, conf)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]

      return false unless 0 <= auxX && auxX <= 9 && 0 <= auxY && auxY <= 9
    end
    true
  end

  def suprapunere_elemente(x, y, conf)
    for aux in 1..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]

      return false if @map[auxX][auxY] == 1 || @map[auxX][auxY] == 3 || @used[auxX][auxY] == 1
    end
    auxX = x + conf[:top][0]
    auxY = y + conf[:left][0]
    return false if @map[auxX][auxY] == 1 || @map[auxX][auxY] == 2 || @used[auxX][auxY] == 1 || @heads[auxX][auxY] > 6
    true
  end

  def marcheaza_configuratia(x, y, conf)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]

      @auxMap[auxX][auxY] = 2
      @used[auxX][auxY] = 1
    end
    @auxMap[x+conf[:top][0]] [y+conf[:left][0]] += 1
  end

  def sterge_configuratia(x, y, conf)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]
  
      @auxMap[auxX][auxY] = 0
      @used[auxX][auxY] = 0
    end
  end

end
