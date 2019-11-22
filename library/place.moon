=>
  @init {}

  if INPUT\mouse_down!
    @start\set INPUT.mouse

  if INPUT\mouse_held!
    if INPUT\key_held 'lshift'
      size = INPUT.mouse - @start!
      draw.rect @start! - size, @start! + size
    else
      draw.rect @start!, INPUT.mouse

  if INPUT\mouse_up!
    size = INPUT.mouse - @start!
    if INPUT\key_held 'lshift'
      table.insert @!, pos: @start!, size: size*2
    else
      table.insert @!, pos: @start! + size/2, size: size

  for o in *@!
    op.add o.pos, o.size
