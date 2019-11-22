{ graphics: lg } = love

import vec2, bound2 from require 'cpml'
import is_once, is_live, are_live, Once from require 'state'
import Object from require 'object'

pushpop = (fn) ->
  (...) ->
    lg.push 'all'
    with fn ...
      lg.pop!

random =
  point: ->
    w, h = lg.getDimensions!
    vec2 w*math.random!, h*math.random!

  size: ->
    vec2 math.random! * 200 + 100, math.random! * 200 + 100

hit =
  radius: (pos, r) ->
    hit.radius2 pos, r*r

  radius2: (pos, r2) ->
    contains = (INPUT.mouse - pos)\len2! < r2
    INPUT\mouse_event! or 'hover' if contains

  line: (frm, to, r2=10) ->
    delta = to - frm
    mouse = INPUT.mouse - frm
    dot = (mouse\dot delta) / delta\len2!
    dot = math.min 1, math.max 0, dot
    p = frm + delta * dot

    hit.radius2 p, r2

  rect: (min, max) ->
    rect = bound2 min, max
    contains = rect\contains INPUT.mouse
    INPUT\mouse_event! or 'hover' if contains

draw =
  cross: (pos) ->
    hs = vec2 8, 8
    mx, my = (pos - hs)\unpack!
    Mx, My = (pos + hs)\unpack!
    
    lg.line mx, my, Mx, My
    lg.line mx, My, Mx, my

    hit.radius2 pos, hs\len2!

  line: (frm, to) ->
    lg.line frm.x, frm.y, to.x, to.y

    hit.line frm, to

  arrow: (frm, to) ->
    dir = (to - frm)\normalize!
    up = dir\perpendicular!
    draw.line to - dir * 15 + up * 7, to
    draw.line to - dir * 15 - up * 7, to

    draw.line frm, to

  rect: (min, max) ->
    x, y = min\unpack!
    w, h = (max - min)\unpack!
    lg.rectangle 'line', x, y, w, h

    hit.rect min, max

  circle: (center, r) ->
    x, y = center\unpack!
    lg.circle 'line', x, y, r

    hit.radius2 center, r*r

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

  line: (frm, to) =>
    input.point @frm, frm
    input.point @to, to

    frm, to = @frm!, @to!
    @set :frm, :to
    draw.line frm, to

  arrow: (frm, to) =>
    input.point @frm, frm
    input.point @to, to

    frm, to = @frm!, @to!
    @set :frm, :to
    draw.arrow frm, to

  rect: do
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
    @init {o,o for o in *SESSION.objects when match and o.name\match init}

    selection = @!
    index = {o,i for i,o in ipairs selection}

    to_remove = {}
    for obj in *SESSION.objects
      selected = index[obj]
      if selected
        draw.cross obj.pos
        -- obj\draw 'line', orng

      if obj\hit! == 'down'
        if selected
          table.insert to_remove, selected
        else
          table.insert selection, obj

    table.sort to_remove
    for i=#to_remove,1,-1
      table.remove selection, to_remove[i]

op =
  move: pushpop (obj, to) ->
    draw.arrow obj.pos, to

    lg.setColor .8, .8, 0
    copy = obj\copy!
    copy.pos = to
    copy\draw!

    if COMMIT
      obj.pos = to

  add: pushpop (pos, size) ->
    tmp = Object pos, size

    lg.setColor 0, .8, 0
    tmp\draw!

    if COMMIT
      table.insert SESSION.objects, tmp

    tmp

  remove: pushpop (obj) ->
    lg.setColor .8, 0, 0
    copy = obj\copy!
    copy\draw!

    if COMMIT
      SESSION.objects = [o for o in *SESSION.objects when o != obj]

  copy: pushpop (obj, pos) ->
    lg.setColor 0, .8, 0
    copy = obj\copy!
    copy.pos = pos
    copy\draw!

    if COMMIT
      table.insert SESSION.objects, copy

    copy

{
  :hit
  :random
  :draw
  :input
  :op
}
