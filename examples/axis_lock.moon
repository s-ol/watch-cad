import vec2 from require 'cpml'

=>
  -- draw helper lines
  origin = vec2 200, 600
  draw.line origin, vec2 200, 0
  draw.line origin, vec2 1000, 600

  -- input two points
  input.line @l, { x: 200 }, { y: 600 }

  -- restrict to first quadrant
  if @l!.frm.y > 600
    @l!.frm.y = 600

  if @l!.to.x < 200
    @l!.to.x = 200
