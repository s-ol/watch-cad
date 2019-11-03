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

love.draw = ->
  SESSION\frame!
  INPUT\frame!
love.keypressed    = INPUT\keypressed
love.keyreleased   = INPUT\keyreleased
love.mousemoved    = INPUT\mousemoved
love.mousepressed  = INPUT\mousepressed
love.mousereleased = INPUT\mousereleased
