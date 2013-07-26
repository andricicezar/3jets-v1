module VlaicuHelper
  def ai1_aiMove4(user_id, id, game)
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
    ai1_search_airplane_heads

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

  def ai1_search_airplane_heads
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 3 && @used[i][j] == 0
          @noAirplanes += 1
          ai1_match_airplane_head(i, j)
          @noAirplanes -= 1
          return
        end
      end
    end
    ai1_search_airplane
  end

  def ai1_match_airplane_head(x, y)
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
      next unless ai1_iese_din_matrice(x, y, confAux)
      next unless ai1_suprapunere_elemente(x, y, confAux)
      ai1_marcheaza_configuratia(x, y, confAux)
      ai1_search_airplane_heads
      ai1_sterge_configuratia(x, y, confAux)
    end
  end


  def ai1_search_airplane
    return if @noAirplanes > 3
    ok = true
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 2 && @used[i][j] == 0
          @noAirplanes += 1
          ai1_match_airplane(i, j)
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

  def ai1_match_airplane(x, y)
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

        next unless ai1_iese_din_matrice(x, y, confAux)
        next unless ai1_suprapunere_elemente(x, y, confAux)
        ai1_marcheaza_configuratia(x, y, confAux)
        ai1_search_airplane
        ai1_sterge_configuratia(x, y, confAux)
      end

      conf = rotate_airplane(conf)
    end

  end

  def ai1_iese_din_matrice(x, y, conf)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]

      return false unless 0 <= auxX && auxX <= 9 && 0 <= auxY && auxY <= 9
    end
    true
  end

  def ai1_suprapunere_elemente(x, y, conf)
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

  def ai1_marcheaza_configuratia(x, y, conf)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]

      @auxMap[auxX][auxY] = 2
      @used[auxX][auxY] = 1
    end
    @auxMap[x+conf[:top][0]] [y+conf[:left][0]] += 1
  end

  def ai1_sterge_configuratia(x, y, conf)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]
  
      @auxMap[auxX][auxY] = 0
      @used[auxX][auxY] = 0
    end
  end


end
