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
  for o in *@objs!
    op.move o, o.pos + delta
