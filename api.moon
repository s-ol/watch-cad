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

  line: (frm, to) ->
    lg.setColor 1, 1, 1
    lg.line frm.x, frm.y, to.x, to.y

    -- @TODO: hit checking

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
  slider: (min=0, max=1) =>
    @init min

    origin = vec2 50, 50
    length = 200
    final = origin + vec2 length, 0
    draw.line origin, final

    if input.point @value, y: origin.y, x: Once min
      val = math.max origin.x, math.min final.x, @value!.x
      @value!.x = val
      @set min + (val - origin.x) / length * max
      return true
  
  point: (fixed={}) =>
    init = if val = is_once fixed
      val
    else
      with random.point!
        if x = is_once fixed.x
          .x = x
        if y = is_once fixed.y
          .y = y
    last = @init init
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
    hh.y /= 2 if live_x
    hh.x /= 2 if live_y

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

  rectangle: do
    meta = size: => @max - @min
    meta.__index = meta

    (fixed={}) =>
      @init setmetatable {}, meta
      delta = input.point @min, fixed.min or Once random.point! * 0.8
      input.point         @max, fixed.max or Once @min! + random.size!
      @max\set @max! + delta if delta

      min, max = @min!, @max!
      draw.rect min, max

      self = @get!
      self.min, self.max = min, max

  circle: (fixed={}) =>
    local tangent
    delta = input.point @center, fixed.center

    radius = (is_live fixed.radius) or do
      radius = (is_once fixed.radius) or math.random! * 100 + 50
      init_tangent = vec2.from_cartesian radius, math.random! * 2 * math.pi
      input.point @tangent, fixed.tangent or Once @center! + init_tangent
      tangent = @tangent!
      radius = @center!\dist tangent
      radius, tangent

    if delta and tangent
      @tangent\set @tangent! + delta

    center, tangent = @center!, @tangent!
    draw.circle center, radius
    @set { :center, :tangent, :radius }

  selection: (pattern) =>
    -- @TOOD: fix
    @init {o for o in *SESSION.objects when match and o.name\match init}

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
