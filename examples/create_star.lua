local vec2 = (require 'cpml').vec2

function draw_star(S)
  input.circle(S.inner)
  input.circle(S.outer, { center = S.inner().center })

  local inner, outer = S.inner(), S.outer()
 
  local cnt = 20
  local step = 2*math.pi/cnt
  local lag  = inner.center + vec2(inner.radius, 0)
  for i = 0, 20 do
    local r = (i % 2 == 0) and inner.radius or outer.radius
    local pos = inner.center + vec2.from_cartesian(r, step * i)

    draw.cross(pos)
    draw.line(pos, lag)
    
    -- obj = Object("object_"..i, pos, vec2(20, 20))
    -- op.add(obj)
    
    lag = pos
  end
end

return draw_star
