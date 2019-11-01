import Input from require 'input'
import State from require 'state'
import Session, Script from require 'session'

export ^

COMMIT = false
INPUT = Input!
STATE = State!
SESSION = Session Script arg[#arg]

for k, v in pairs require 'api'
  _G[k] = v

for event in *{'keypressed', 'keyreleased', 'mousepressed', 'mousereleased'}
  love[event] = (...) -> INPUT[event] INPUT, ...

love.draw = SESSION\frame

require 'moon.all'

-- Move = (obj, x, y) ->
--   if COMMIT
--     obj.x = x
--     obj.y = y
--     return
--
--   lg.setColor orng
--   lg.line x + obj.w/2, y + obj.h/2, obj\center!
--   obj = obj\clone!
--   obj.x = x
--   obj.y = y
--   obj\draw 'line', orng
--
-- Add = (obj) ->
--   if COMMIT
--     table.insert OBJS, obj
--     return
--
--   obj\draw 'line', gren
--
-- class Object
--   new: (@name, @x, @y, @w=60, @h=30) =>
--
--   center: =>
--     @x + @w/2, @y + @h/2
--
--   draw: (mode, color) =>
--     rect @x, @y, @w, @h, :mode, :color
--
--   clone: =>
--     Object "", @x, @y, @w,  @h
--
--   hit: =>
--     mx, my = lm.getPosition!
--     (lm.justDown!) and @x < mx and @x + @w > mx and @y < my and @y + @h > my

-- OBJS = {
--   Object 'led-1', 50, 50
--   Object 'led-2', 50, 150
--   Object 'led-3', 150, 50
--   Object 'led-3', 250, 150
--   Object 'btn', 150, 150, 40, 40
-- }
