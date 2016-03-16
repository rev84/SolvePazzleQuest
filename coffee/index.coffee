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

  @getChain:(cells = @cells)->
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