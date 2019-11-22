local vec2 = (require 'cpml').vec2

function draw_star(S)
  input.circle(S.inner)
  input.circle(S.outer, { center = S.inner().center })

  local inner, outer = S.inner(), S.outer()

  input.slider(S.cnt, 2, 20)
  
  local cnt = math.floor(S.cnt()) * 2
  local step = 2*math.pi/cnt
  local lag  = inner.center + vec2(inner.radius, 0)
  for i = 0, cnt do
    local r = (i % 2 == 0) and inner.radius or outer.radius
    local pos = inner.center + vec2.from_cartesian(r, step * i)

    op.add(pos, vec2(20, 20))
    draw.line(pos, lag)
    
    lag = pos
  end
end

return draw_star
