print "scratch buffer is #{file}"
lfs = require 'lfs'
require 'moon.all'

love.timer = nil

{ graphics: lg, mouse: lm } = love

red = { 1, 0, 0 }
turk = { 0, 1, 1 }
orng = { .6, .5, 0 }
gren = { 0, .8, 0 }

rect = (x, y, w, h, opts={mode: 'line'}) ->
  lg.setColor opts.color if opts.color
  lg.rectangle opts.mode, x, y, w, h

  mx, my = lm.getPosition!
  (lm.isDown 1) and x < mx and x + w > mx and y < my and y + h > my

export ^
COMMIT = false

Move = (obj, x, y) ->
  if COMMIT
    obj.x = x
    obj.y = y
    return

  lg.setColor orng
  lg.line x + obj.w/2, y + obj.h/2, obj\center!
  obj = obj\clone!
  obj.x = x
  obj.y = y
  obj\draw 'line', orng

Add = (obj) ->
  if COMMIT
    table.insert OBJS, obj
    return

  obj\draw 'line', gren

Select_objs = (match) =>
  if not @selection
    @selection = {o for o in *OBJS when match and o.name\match match}

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

Select_rect = =>
  { :x, :y, :w, :h } = @rect or { x: 222, y: 200, w: 400, h: 200 }

  opts = mode: 'line', color: turk
  rect x, y, w, h, opts

  if rect x, y, 30, 30, opts
    dx, dy = lm.getDelta!
    x += dx
    y += dy
    w -= dx
    h -= dy
  if rect x + w - 30, y + h - 30, 30, 30, opts
    dx, dy = lm.getDelta!
    w += dx
    h += dy

  @rect = { :x, :y, :w, :h }
  @rect


Select_circle = (cx, cy) =>
  @circ or= do
    r = math.random! * 100 + 50
    a = math.random! * math.pi * 2 * 50 + 50
    hx, hy = r * math.cos(a), r * math.sin(a)
    { cx: 150, cy: 150, :hx, :hy, :r }

  { :r, :hx, :hy } = @circ
  if cx and cy
    @fix_center = true
  else
    { :cx, :cy } = @circ

  lg.setColor turk
  lg.circle 'line', cx, cy, r

  opts = color: turk, mode: 'line'

  if not @fix_center
    if rect cx - 15, cy - 15, 30, 30, opts
      dx, dy = lm.getDelta!
      cx += dx
      cy += dy

  if rect cx + hx - 15, cy + hy - 15, 30, 30
    dx, dy = lm.getDelta!
    hx += dx
    hy += dy


  @circ = { :cx, :cy, :hx, :hy, r: math.sqrt hx*hx + hy*hy }
  @circ

update_script = do
  file = arg[2]
  last_mod = 0
  last_script = ->

  wrapper = () ->
    ok, err = pcall last_script

    if ok and 'function' != type err
      ok = false
      err = 'script did not return a function'

    if not ok
      print "--- ERROR EXECUTING SCRIPT: ---"
      print err
      return

    ok, err = pcall err, STATE
    if not ok
      print "--- ERROR EXECUTING SCRIPT: ---"
      print err

  print "watching '#{file}'..."
  ->
    mod = lfs.attributes file, 'modification'
    if last_mod < mod
      last_mod = mod
      script, err = loadfile file
      if script
        last_script = script
      else
        print "--- ERROR PARSING SCRIPT: ---"
        print err

    wrapper


class Object
  new: (@name, @x, @y, @w=60, @h=30) =>

  center: =>
    @x + @w/2, @y + @h/2

  draw: (mode, color) =>
    rect @x, @y, @w, @h, :mode, :color

  clone: =>
    Object "", @x, @y, @w,  @h

  hit: =>
    mx, my = lm.getPosition!
    (lm.justDown!) and @x < mx and @x + @w > mx and @y < my and @y + @h > my

OBJS = {
  Object 'led-1', 50, 50
  Object 'led-2', 50, 150
  Object 'led-3', 150, 50
  Object 'led-3', 250, 150
  Object 'btn', 150, 150, 40, 40
}

lm.doesHit = (x, y, w, h) ->
  mx, my = lm.getPosition!

mkstate = -> setmetatable {}, __index: (t, k) ->
  with val = {}
    rawset t, k, val
STATE = mkstate!

commit = ->
  COMMIT = true
  print "COMMITTING"
  script = update_script!
  script!
  STATE = mkstate!
  COMMIT = false

local last_mx, last_my, last_down
love.draw = ->
  script = update_script!

  for obj in *OBJS
    obj\draw 'fill', red

  script!

  last_mx, last_my = lm.getPosition!
  last_down = lm.isDown 1

love.keypressed = (key) ->
  if key == 'return'
    commit!
  if key == 'escape'
    STATE = mkstate!

lm.justDown = ->
  (lm.isDown 1) and not last_down

lm.getDelta = ->
  mx, my = lm.getPosition!
  mx - last_mx, my - last_my
