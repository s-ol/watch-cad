{ graphics: lg } = love

import vec2, bound2 from require 'cpml'

random =
  point: ->
    w, h = love.graphics.getDimensions!
    vec2 w*math.random!, h*math.random!

  size: ->
    vec2 math.random! * 200 + 100, math.random! * 200 + 100

draw =
  rect: (mode, min, max) ->
    x, y = min\unpack!
    w, h = (max - min)\unpack!
    lg.setColor 1, 1, 1
    lg.rectangle 'line', x, y, w, h

    rect = bound2 min, max
    contains = rect\contains INPUT.mouse
    contains and (not mode or INPUT["mouse_#{mode}"] INPUT, 1)

  circle: (mode, center, r) ->
    x, y = center\unpack!
    lg.setColor 1, 1, 1
    lg.circle 'line', x, y, r

    contains = (INPUT.mouse - center)\len! < r
    contains and (not mode or INPUT["mouse_#{mode}"] INPUT, 1)

half_handle = vec2 15, 15
input =
  dot: (init, fixed) =>
    init or= random.point!

    if fixed == true
      return init
    
    fixed or= x: false, y: false
    @pos = (rawget @, 'pos') or init

    if draw.rect 'held', @pos - half_handle, @pos + half_handle
      delta = INPUT\mouse_delta!
      @pos = @pos + delta

    @pos.x = init.x if fixed.x
    @pos.y = init.y if fixed.y

    @pos

  rectangle: (init={}, fixed={}) =>
    init.min or= random.point! * 0.8
    init.max or= init.min + random.size!
    @last_min = (rawget @, 'last_min') or init.min

    max = input.dot @max, init.max, fixed.max
    min = input.dot @min, init.min, fixed.min
    delta = @last_min - min
    max += delta
    @last_min = min

    draw.rect nil, min, max
    { :min, :max }

  circle: (init={}, fixed={}) =>
    init.center or= random.point!
    init.radius or= math.random! * 100 + 50
    init.tangent or= do
      angle = math.random! * math.pi * 2
      init.center + vec2.from_cartesian init.radius, angle
    
    center  = input.dot @c, init.center, fixed.center

    local tangent, radius
    if fixed.radius
      radius = init.radius
    else
      tangent = input.dot @t, init.tangent, fixed.tangent
      radius = (tangent - center)\len!

    draw.circle nil, center, radius

    { center, tangent, :radius }

  selection: (init, fixed) =>
    init or= {o for o in *OBJS when match and o.name\match init}

    lg.push 'all'
    lg.setLineWidth 5
    for obj in *OBJS
      selected = @selection[obj]
      if selected
        obj\draw 'line', orng

      if obj\hit!
        @selection[obj] = if selected then nil else obj

    lg.pop!

    [o for o in pairs @selection]

{
  :random
  :draw
  :input
}
