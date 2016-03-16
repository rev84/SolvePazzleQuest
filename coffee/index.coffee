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

  @eCells = []
  @cells  = []

  @init:->
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
    cells = [
        @CONST_CELL_GREEN 
        @CONST_CELL_RED
        @CONST_CELL_YELLOW
        @CONST_CELL_BLUE
        @CONST_CELL_GOLD
        @CONST_CELL_EXP
        @CONST_CELL_SKULL
    ]
    for x in [0...@CONST_X]
      for y in [0...@CONST_Y]
        @cells[x][y] = cells[Utl.rand(0, cells.length-1)]
    @redraw()

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