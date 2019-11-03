{ graphics: lg } = love

import vec2, bound2 from require 'cpml'
import is_once, is_live, are_live, Once from require 'state'

random =
  point: ->
    w, h = lg.getDimensions!
    vec2 w*math.random!, h*math.random!

  size: ->
    vec2 math.random! * 200 + 100, math.random! * 200 + 100

draw =
  cross: (pos) ->
    hs = vec2 8, 8
    mx, my = (pos - hs)\unpack!
    Mx, My = (pos + hs)\unpack!
    
    lg.setColor 1, 1, 1
    lg.line mx, my, Mx, My
    lg.line mx, My, Mx, my

    contains = (INPUT.mouse - pos)\len2! < hs\len2!
    INPUT\mouse_event! if contains

  rect: (min, max) ->
    x, y = min\unpack!
    w, h = (max - min)\unpack!
    lg.setColor 1, 1, 1
    lg.rectangle 'line', x, y, w, h

    rect = bound2 min, max
    contains = rect\contains INPUT.mouse
    INPUT\mouse_event! if contains

  circle: (center, r) ->
    x, y = center\unpack!
    lg.setColor 1, 1, 1
    lg.circle 'line', x, y, r

    contains = (INPUT.mouse - center)\len! < r
    INPUT\mouse_event! if contains

half_handle = vec2 15, 15
input =
  point: (fixed={}) =>
    last = @init random.point!
    pos = last\clone!

    live_x, live_y = (is_live fixed.x), is_live fixed.y

    pos.x = fixed.x if live_x
    pos.y = fixed.y if live_y

    -- both values are 'live', no UI necessary
    if live_x and live_y
      draw.cross pos
      @set pos
      delta = pos - last
      return delta\len2! > 0 and delta

    -- handle size (square or rect)
    hh = half_handle\clone!
    hh.x /= 2 if live_x
    hh.y /= 2 if live_y

    if 'down' == draw.rect pos - hh, pos + hh
      @drag\set true

    if @drag!
      if INPUT\mouse_up!
        @drag\set false

      delta = INPUT\mouse_delta!
      delta.x = 0 if live_x
      delta.y = 0 if live_y
      pos += delta

    @set pos
    delta = last and pos - last
    return delta and delta\len2! > 0 and delta

  rectangle: (fixed={}) =>
    delta = input.point @min, fixed.min or Once random.point! * 0.8
    input.point         @max, fixed.max or Once @min! + random.size!
    @max\set @max! + delta if delta

    min, max = @min!, @max!
    draw.rect min, max
    @set { :min, :max }

  circle: (fixed={}) =>
    local tangent
    delta = input.point @center, fixed.center

    radius = (is_live fixed.radius) or do
      radius = (is_once fixed.radius) or math.random! * 100 + 50
      init_tangent = vec2.from_cartesian radius, math.random! * 2 * math.pi
      input.point @tangent, fixed.tangent or Once @center! + init_tangent
      @center!\dist @tangent!

    @tangent\set @tangent! + delta if delta and tangent

    center, tangent = @center!, @tangent!
    draw.circle center, radius
    { :center, :tangent, :radius }

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
