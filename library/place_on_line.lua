function place_on_line(S)
  input.selection(S.objs, '^led-')
  input.line(S.dest)

  local dest = S.dest()
  local start = dest.frm
  local step = (dest.to - dest.frm) / #S.objs()
  start = start - step/2

  for i, obj in ipairs(S.objs()) do
    local pos = start + step * i
    op.move(obj, pos)
  end
end

return place_in_rect
