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

def afiseaza(harta)
  for i in 0..9 do
    puts i.to_s + " " + harta[i].inspect.to_s
  end
  puts
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
  return false if @map[auxX][auxY] == 1 || @map[auxX][auxY] == 2 || @used[auxX][auxY] == 1
  true
end

def add_airplane(harta, type, top, left, rotation, ok = false)

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

def copyMap(x, y)
  for i in 0..9
    x[i] = y[i].dup
  end
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

def marcheaza_configuratia(x, y, conf, ok = false)
  for aux in 0..9 do
    auxX = x + conf[:top][aux]
    auxY = y + conf[:left][aux]
    @harta[auxX][auxY] += 1
    if ok
      @harta[auxX][auxY] = 1
      @used[auxX][auxY] = 1
    end
  end
end

# AUX

def put_airplane(x, y)
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
    end

    conf = rotate_airplane(conf)
  end
end

def generare
  @harta = createMap
  for i in 0..9 do
    for j in 0..9 do
      if @map[i][j] == 2 && @used[i][j] == 0
        put_airplane(i, j)
      end
    end
  end
end

def try_to_fix_with_head(x, y)
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
    next unless iese_din_matrice(x, y, confAux)
    next unless suprapunere_elemente(x, y, confAux)
    numarPos += 1
    poz = i
    # check if is one
    ok = 10
    for aux in 0..9 do
      auxX = x + confAux[:top][aux]
      auxY = y + confAux[:left][aux]
      ok -= 1 if (@harta[auxX][auxY] == 1)
      ok = 0 if (@harta[auxX][auxY] == 0)
    end
    if ok > 0
      @noAirplanes += 1
      marcheaza_configuratia(x, y, confAux, true)
    end
  end

  if numarPos == 1
    for i in 0..poz do
      conf = rotate_airplane(conf)
    end

    marcheaza_configuratia(x, y, conf, true)
    @noAirplanes += 1
    return true
  end
  return false
end

# AI

def ai2_search_heads
  generare
  # caut fiecare cap
  for i in 0..9 do
    for j in 0..9 do
      if @map[i][j] == 3 && @used[i][j] == 0
        if try_to_fix_with_head(i, j)
          ai2_search_heads
          return
        end
      end
    end
  end
end


# INITIALIZARE
#

@map = createMap
@harta = createMap
@used = createMap
@noAirplanes = 0
@map[4][4] = 2
@map[2][4] = 1
@map[4][3] = 1
@map[5][4] = 1
@map[4][7] = 1
@map[7][5] = 3
ai2_search_heads

afiseaza @used
