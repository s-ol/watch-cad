-- return function (state)
function place_in_rect(S)
  input.selection(S.objs, '^led-')
  input.rect(S.dest)

  local start = S.min()
  local step = S.dest():size()
  step.y = 0

  for i, obj in ipairs(S.objs()) do
    local pos = start + step:scale(i)
    draw.cross(pos)
    -- op.move(obj, pos)
  end
end

return place_in_rect
