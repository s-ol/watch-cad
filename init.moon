import Input from require 'input'
import State from require 'state'
import Session, Script from require 'session'
profile = require 'profile'

export ^

COMMIT = false
INPUT = Input!
STATE = State!
SESSION = Session Script arg[#arg]

for k, v in pairs require 'api'
  _G[k] = v

love.draw = ->
  p = INPUT\key_down 'p'
  if p
    profile.reset!
    profile.start!
  SESSION\frame!
  INPUT\frame!
  if p
    profile.stop!
    print love.timer.getFPS!
    print profile.report 20
love.keypressed    = INPUT\keypressed
love.keyreleased   = INPUT\keyreleased
love.mousemoved    = INPUT\mousemoved
love.mousepressed  = INPUT\mousepressed
love.mousereleased = INPUT\mousereleased
