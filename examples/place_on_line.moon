=>
  input.selection @objs
  input.line @dest

  dest = @dest!
  step = (dest.to - dest.frm) / #@objs!

  for i, obj in ipairs @objs!
    pos = dest.frm + step * (i - .5)
    op.move obj, pos
