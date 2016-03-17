class PuzzleQuest
  @CONST_X = 8
  @CONST_Y = 8

  @CONST_CELL_EMPTY  = null
  @CONST_CELL_GREEN  = 10
  @CONST_CELL_RED    = 20
  @CONST_CELL_YELLOW = 30
  @CONST_CELL_BLUE   = 40
  @CONST_CELL_GOLD   = 100
  @CONST_CELL_EXP    = 110
  @CONST_CELL_SKULL  = 120
  @CONST_CELL_SKULL5 = 130

  @initialized = false
  @eCells = []
  @cells  = []

  @init:->
    return if @initialized
    @initialized = true

    # セルの初期化
    @eCells = Utl.array2dFill(@CONST_X, @CONST_Y)
    @cells = Utl.array2dFill(@CONST_X, @CONST_Y, @CONST_CELL_EMPTY)
    for y in [0...@CONST_Y]
      tr = $('<tr>')
      for x in [0...@CONST_X]
        td = $('<td>').addClass('cell').appendTo(tr)
        @eCells[x][y] = td

      $('#board tbody').append tr

  @getScores:(cells = @cells)->
    scores = []
    for x in [0...cells.length]
      for y in [0...cells[x].length]
        # 右と入れ替える
        score = 0
        if x+1 < cells.length
          copy = Utl.clone cells
          [copy[x][y], copy[x+1][y]] = [copy[x+1][y], copy[x][y]]
          score += @getScore copy
        scores.push {
          x : x
          y : y
          direction : "x"
          score : score
        }

        # 下と入れ替える
        score = 0
        if y+1 < cells[x].length
          copy = Utl.clone cells
          [copy[x][y], copy[x][y+1]] = [copy[x][y+1], copy[x][y]]
          score += @getScore copy
        scores.push {
          x : x
          y : y
          direction : "y"
          score : score
        }

    scores.sort (a, b)->
      return 1  if a.score < b.score
      return -1 if a.score > b.score
      0

    scores

  @getScore:(inputCells)->
    cells = Utl.clone inputCells
    chains = @getChain cells

    score = 0
    # 連鎖があるとき
    if chains.length isnt 0
      firstScore = 0
      for chain in chains
        # 3消しなら1点
        if chain.length is 3
          firstScore += 1
        # 4消し以上なら100点
        else if chain.length >= 4
          firstScore += 100

        for tempChain in chain
          [tempX, tempY] = tempChain
          cells[tempX][tempY] = @CONST_CELL_EMPTY

      # 自由落下
      cells = @fall(cells)
      # 空の座標を探す
      emptyCells = []
      for x in [0...cells.length]
        for y in [0...cells[x].length]
          emptyCells.push [x, y] if cells[x][y] is @CONST_CELL_EMPTY
      # 二乗回ランダムに試す
      randScore = 0
      for n in [0...1000]
        for e in emptyCells
          cells[e[0]][e[1]] = (->
            c = [
              @CONST_CELL_GREEN 
              @CONST_CELL_RED
              @CONST_CELL_YELLOW
              @CONST_CELL_BLUE
              @CONST_CELL_GOLD
              @CONST_CELL_EXP
              @CONST_CELL_SKULL
            ]
            c[Utl.rand(0, c.length-1)]
          )()
        randScore += @getScore cells
      randScore /= 1000
      score += firstScore + randScore
    score

  @randomize:->
    @init()
    cells = [
        @CONST_CELL_GREEN 
        @CONST_CELL_RED
        @CONST_CELL_YELLOW
        @CONST_CELL_BLUE
        @CONST_CELL_GOLD
        @CONST_CELL_EXP
        @CONST_CELL_SKULL
    ]
    flag = true
    while flag
      for x in [0...@CONST_X]
        for y in [0...@CONST_Y]
          @cells[x][y] = cells[Utl.rand(0, cells.length-1)]
      flag = @getChain().length isnt 0
    @redraw()

  @getChain:(inputCells = @cells)->
    cells = Utl.clone inputCells

    chains = []
    for x in [0...cells.length]
      for y in [0...cells[x].length]
        # 自身
        me = cells[x][y]

        # 右方向に走査
        unless 0 < x and @isChainable(me, cells[x-1][y])
          tempChain = [[x, y]]
          for xPlus in [x+1...cells.length]
            break unless @isChainable(me, cells[xPlus][y])
            tempChain.push [xPlus, y]
          if tempChain.length >= 3
            chains.push tempChain

        # 下方向に走査
        unless 0 < y and @isChainable(me, cells[x][y-1])
          tempChain = [[x, y]]
          for yPlus in [y+1...cells[x].length]
            break unless @isChainable(me, cells[x][yPlus])
            tempChain.push [x, yPlus]
          if tempChain.length >= 3
            chains.push tempChain
    chains

  # 自由落下させる
  @fall:(inputCells = @cells)->
    cells = Utl.clone inputCells

    for x in [0...cells.length]
      temp = []
      for y in [0...cells[x].length]
        if cells[x][y] isnt @CONST_CELL_EMPTY
          temp.push cells[x][y]
      temp.unshift @CONST_CELL_EMPTY for i in [0...cells[x].length-temp.length]
      cells[x] = temp
    cells

  # 連鎖の対象になるか
  @isChainable:(me, target)->
    chainable = switch me
      when @CONST_CELL_RED    then [@CONST_CELL_RED]
      when @CONST_CELL_GREEN  then [@CONST_CELL_GREEN]
      when @CONST_CELL_YELLOW then [@CONST_CELL_YELLOW]
      when @CONST_CELL_BLUE   then [@CONST_CELL_BLUE]
      when @CONST_CELL_GOLD   then [@CONST_CELL_GOLD]
      when @CONST_CELL_EXP    then [@CONST_CELL_EXP]
      when @CONST_CELL_SKULL  then [@CONST_CELL_SKULL, @CONST_CELL_SKULL5]
      else []
    Utl.inArray target, chainable


  @redraw:->
    for x in [0...@CONST_X]
      for y in [0...@CONST_Y]
        img = switch @cells[x][y]
          when @CONST_CELL_RED    then 'red'
          when @CONST_CELL_GREEN  then 'green'
          when @CONST_CELL_YELLOW then 'yellow'
          when @CONST_CELL_BLUE   then 'blue'
          when @CONST_CELL_GOLD   then 'gold'
          when @CONST_CELL_EXP    then 'exp'
          when @CONST_CELL_SKULL  then 'skull'
        @eCells[x][y].css('background-image', 'url(./img/'+img+'.png)')


$ ->
  PuzzleQuest.init()