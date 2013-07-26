module HeriHelper
  def ai2_aiMoveHeri(user_id, id, game)
    @map = createMap
    @harta = createMap
    @used = createMap
    @auxHarta = createMap
    @noAirplanes = 0
    @headSelected = []
    @headsSelected = []
    @max = 0

    moves = Move.where(:game_id => game.id, :user_id => id)
    moves.each do |move|
      @map[move.top][move.left] = move.hit + 1
    end

    ai2_generare
    ai2_search_heads

    puts @headsSelected.inspect
    if @headsSelected.length < 5 && !@headsSelected.empty?
      @lastMove = @headsSelected[ Random.rand(@headsSelected.length)-1 ]
    elsif !@headsSelected.empty?
      max = 0
      for i in 0..9 do
        for j in 0..9 do
          if @map[i][j] == 0
            if max <= @harta[i][j]
              max = @harta[i][j]
              @lastMove = [i, j]
            end
          end
        end
      end
    end
    finish_ai(user_id, game, @lastMove)
  end

  def ai2_iese_din_matrice(x, y, conf)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]

      return false unless 0 <= auxX && auxX <= 9 && 0 <= auxY && auxY <= 9
    end
    true
  end

  def ai2_suprapunere_elemente(x, y, conf)
    for aux in 1..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]

      return false if @map[auxX][auxY] == 1 || @map[auxX][auxY] == 3 || @used[auxX][auxY] == 1
    end
    auxX = x + conf[:top][0]
    auxY = y + conf[:left][0]
    return false if @map[auxX][auxY] == 1 || @map[auxX][auxY] == 2 || @used[auxX][auxY] == 1
    true
  end

  def ai2_dd_airplane(harta, type, top, left, rotation, ok = false)

    conf = {
      :top =>  [3, 0, 0, 0, 1, 2, 2, 2, 2, 2],
      :left => [2, 1, 2, 3, 2, 0, 1, 2, 3, 4]}

    (rotation-1).times do
      conf = rotate_airplane(conf)
    end
    for aux in 1..9 do
      conf[:top][aux] -= conf[:top][0]
      conf[:left][aux] -= conf[:left][0]
    end

    conf[:top][0] = 0
    conf[:left][0] = 0
    for i in 0..9 do
      harta[ conf[:top][i] + top ][ conf[:left][i] + left ] += 1
    end

    if ok
      harta[ conf[:top][0] + top ][ conf[:left][0] + left ] += 1
    end

    harta
  end

  def createMap
    harta = []
    for i in 0..9 do
      harta[i] = []
      for j in 0..9 do
        harta[i][j] = 0
      end
    end
    harta
  end

  def ai2_marcheaza_configuratia(x, y, conf, ok = false, ok2 = true, ok3 = true)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]
      @harta[auxX][auxY] += 1 if ok3
      @used[auxX][auxY] = 1 if ok2
      if ok
        @harta[auxX][auxY] = 1
      end
    end
  end

  def ai2_sterge_configuratia(x, y, conf, ok = false)
    for aux in 0..9 do
      auxX = x + conf[:top][aux]
      auxY = y + conf[:left][aux]
      @harta[auxX][auxY] = 0 if ok

      @used[auxX][auxY] = 0
    end
  end


  # AUX
  def ai2_put_airplane(x, y)
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

        next unless ai2_iese_din_matrice(x, y, confAux)
        next unless ai2_suprapunere_elemente(x, y, confAux)

        ai2_marcheaza_configuratia(x, y, confAux, false, false)
      end

      conf = rotate_airplane(conf)
    end
  end

  def ai2_put_airplane2(x, y)
    conf = {
      :top =>  [3, 0, 0, 0, 1, 2, 2, 2, 2, 2],
      :left => [2, 1, 2, 3, 2, 0, 1, 2, 3, 4]}
    confAux = {}
    for i in 0..3 do
      conf = rotate_airplane(conf)

      confAux[:top] = conf[:top].dup
      confAux[:left] = conf[:left].dup
      for aux in 1..9 do
        confAux[:top][aux] -= conf[:top][0]
        confAux[:left][aux] -= conf[:left][0]
      end
      confAux[:top][0] = 0
      confAux[:left][0] = 0

      next unless ai2_iese_din_matrice(x, y, confAux)
      next unless ai2_suprapunere_elemente(x, y, confAux)

      for aux in 0..9 do
        auxX = x + confAux[:top][aux]
        auxY = y + confAux[:left][aux]

        @auxHarta[auxX][auxY] += 1
      end

    end

  end

  def ai2_generare
    puts "Generam"
    @harta = createMap
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 2 && @used[i][j] == 0
          ai2_put_airplane(i, j)
        end
      end
    end
  end

  def ai2_generare2
    puts "Generam2"
    @harta = createMap
    for i in 0..9 do
      for j in 0..9 do
        if @used[i][j] == 0
          ai2_put_airplane2(i, j)
        end
      end
    end
  end

  def ai2_try_to_fix_with_head(x, y)
    conf = {
      :top =>  [3, 0, 0, 0, 1, 2, 2, 2, 2, 2],
      :left => [2, 1, 2, 3, 2, 0, 1, 2, 3, 4]}
    confAux = {}
    numarPos = 0
    poz = 0
    for i in 0..3 do
      conf = rotate_airplane(conf)
      confAux[:top] = conf[:top].dup
      confAux[:left] = conf[:left].dup
      for aux in 0..9 do
        confAux[:top][aux] -= conf[:top][0]
        confAux[:left][aux] -= conf[:left][0]
      end
      next unless ai2_iese_din_matrice(x, y, confAux)
      next unless ai2_suprapunere_elemente(x, y, confAux)
      numarPos += 1
      poz = i
      # check if is one
      ok = 1
      for aux in 0..9 do
        auxX = x + confAux[:top][aux]
        auxY = y + confAux[:left][aux]
        ok -= 1 if (@harta[auxX][auxY] == 1)
        ok = 0 if (@harta[auxX][auxY] == 0)
      end
      if ok > 0
        @noAirplanes += 1
        ai2_marcheaza_configuratia(x, y, confAux, true)
        return true
      end
    end

    if numarPos == 1
      for i in 0..poz do
        conf = rotate_airplane(conf)
      end
      for aux in 1..9 do
        conf[:top][aux] -= conf[:top][0]
        conf[:left][aux] -= conf[:left][0]
      end
      conf[:top][0] = 0
      conf[:left][0] = 0

      ai2_marcheaza_configuratia(x, y, conf, true)
      @noAirplanes += 1
      return true
    end
    return false
  end

  def ai2_try_head(x, y)
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
      next unless ai2_iese_din_matrice(x, y, confAux)
      next unless ai2_suprapunere_elemente(x, y, confAux)
      ai2_marcheaza_configuratia(x, y, confAux)
      ai2_search_unfixed_heads
      ai2_sterge_configuratia(x, y, confAux)
    end
  end

  def ai2_match_airplane(x, y)
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

        next unless ai2_iese_din_matrice(x, y, confAux)
        next unless ai2_suprapunere_elemente(x, y, confAux)
        ai2_marcheaza_configuratia(x, y, confAux, false, true, false)
        ai2_search_hits
        ai2_sterge_configuratia(x, y, confAux)
      end

      conf = rotate_airplane(conf)
    end
  end


  # AI
  def ai2_nothing
    puts "      Search nothing"
    auxHarta2 = createMap
    copyMap(auxHarta2, @auxHarta)
    ai2_generare2 if @noAirplanes <= 3
    for i in 0..9 do
      for j in 0..9 do
        if @max < @auxHarta[i][j]
          @max = @auxHarta[i][j]
          @lastMove = [i, j]
        end
      end
    end

    copyMap(@auxHarta, auxHarta2)
  end

  def ai2_search_hits
    return if @noAirplanes > 3
    puts "    Search hits"
    max = 0
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 2 && @used[i][j] == 0
          @noAirplanes += 1
          ai2_match_airplane(i, j)
          @noAirplanes -= 1
          return
        end
      end
    end
    if @headsSelected.last != @headSelected
      @headsSelected << @headSelected
    end
  end

  def ai2_match_airplane2(x, y)
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

        next unless ai2_iese_din_matrice(x, y, confAux)
        next unless ai2_suprapunere_elemente(x, y, confAux)
        ai2_marcheaza_configuratia(x, y, confAux)
        @headSelected = [x + confAux[:top][0], y + confAux[:left][0]]
        ai2_search_hits
        ai2_sterge_configuratia(x, y, confAux)
      end

      conf = rotate_airplane(conf)
    end
  end

  def ai2_search_first_hit
    puts "    Search first hit"
    max = 0
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 2 && @used[i][j] == 0
          @noAirplanes += 1
          ai2_match_airplane2(i, j)
          @noAirplanes -= 1
          return
        end
      end
    end
    ai2_nothing
  end

  def ai2_search_unfixed_heads
    puts "  Search unfixed heads"
    # caut fiecare cap mobil
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 3 && @used[i][j] == 0
          @noAirplanes += 1
          ai2_try_head(i, j)
          return
        end
      end
    end
    @harta = createMap
    ai2_search_first_hit
  end

  def ai2_search_heads
    puts "Search heads"
    # caut fiecare cap si vad care sunt fixe
    for i in 0..9 do
      for j in 0..9 do
        if @map[i][j] == 3 && @used[i][j] == 0
          if ai2_try_to_fix_with_head(i, j)
            ai2_generare
            ai2_search_heads
            return
          end
        end
      end
    end

    ai2_search_unfixed_heads
  end


end
