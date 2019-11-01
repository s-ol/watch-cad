{ graphics: lg } = love

import vec2, bound2 from require 'cpml'
import is_once, is_live, are_live, Once from require 'state'

random =
  point: ->
    w, h = love.graphics.getDimensions!
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
    if vec = is_once fixed
      fixed = {
        x: Once vec.x
        y: Once vec.y
      }

    init = random.point!
    @store 'x', fixed.x, init.x
    @store 'y', fixed.y, init.y
    pos = vec2 @x, @y

    -- both values are 'live', no UI necessary
    if are_live fixed.x, fixed.y
      draw.cross pos
      return pos

    hh = half_handle\clone!
    hh.x /= 2 if is_live fixed.x
    hh.y /= 2 if is_live fixed.y

    @init 'drag', false
    if 'down' == draw.rect pos - hh, pos + hh
      @drag = true

    if @drag
      @drag = false if INPUT\mouse_up!

      pos += INPUT\mouse_delta!

      @store 'x', pos.x unless is_live fixed.x
      @store 'y', pos.y unless is_live fixed.y

    vec2 @x, @y

  point_relative_to: (other, fixed) =>
    assert (is_live other), "other needs to be live!"

    @init 'last_other', other
    @init 'last', fixed or random.point!
    delta = other - @last_other

    val = if delta\len2! > 0 and not is_live fixed
      input.point @, @last + delta
    else
      input.point @, fixed or Once @last

    @store 'last_other', other
    @store 'last', val

    val

  rectangle: (fixed={}) =>
    min = input.point @min, fixed.min or Once random.point! * 0.8
    max = input.point_relative_to @max, min, fixed.max or Once min + random.size!

    draw.rect min, max
    { :min, :max }

  circle: (fixed={}) =>
    local tangent
    center = input.point @center, fixed.center
    radius = (is_live fixed.radius) or do
      radius = (is_once fixed.radius) or math.random! * 100 + 50
      init_tangent = vec2.from_cartesian radius, math.random! * 2 * math.pi
      tangent = input.point_relative_to @tangent, center, fixed.tangent or Once center + init_tangent
      center\dist tangent

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
