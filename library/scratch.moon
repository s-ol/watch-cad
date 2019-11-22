import vec2 from require 'cpml'

=>
  input.selection @objs

  center = vec2!
  for o in *@objs!
    center += o.pos
  num = #@objs!
  if num > 0
    center /= num
  input.arrow @delta, center

  delta = @delta!.to - @delta!.frm
  -- delta.x = 25 * math.floor delta.x / 25
  -- delta.y = 25 * math.floor delta.y / 25
  for o in *@objs!
    op.copy  o, o.pos + delta
