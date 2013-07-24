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

def check_map(harta)
  ok = false
  for i in 0..9 do
    for j in 0..9 do
      if harta[i][j] > 1
        return false
      end
    end
  end
  return true
end

def copyMap(x, y)
  for i in 0..9
    x[i] = y[i].dup
  end
end
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
  puts conf
