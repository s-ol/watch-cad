-- return function (state)
function place_in_rect(state)
  selection = Select_objs(state.objs, '^led-')
  rect = Select_rect(state.dest)

  sx = rect.w / (#selection + 1)

  x = sx
  for i, obj in ipairs(selection) do
    Move(obj, rect.x + x - obj.w/2, rect.y)
    x = x + sx
  end
end

function create_star(state)
  local inner = Select_circle(state.inner)
  local outer = Select_circle(state.outer, inner.cx, inner.cy)

  cnt = 20
  step = 2*math.pi/cnt
  lag_x, lag_y = inner.cx + inner.r, inner.cy
  for i = 0, 20 do
    r = (i % 2 == 0) and inner.r or outer.r
    x = inner.cx + math.cos(step * i) * r
    y = inner.cy + math.sin(step * i) * r
    obj = Object("object_"..i, x-10, y-10, 20, 20)
    Add(obj)
    
    love.graphics.line(lag_x, lag_y, obj:center())
    lag_x, lag_y = obj:center()
  end
end

function test(S)
  rect = input.rectangle(S.rect)

  input.circle(S.circle, { center = rect.min, radius = 100 }, { center = true, radius = true })
end

return test
