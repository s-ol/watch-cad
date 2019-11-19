import Input from require 'input'
import State from require 'state'
import Session, Script from require 'session'
profile = require 'profile'

export ^

for k, v in pairs require 'api'
  _G[k] = v

scriptfile = arg[#arg]
scriptfile = nil if scriptfile == '.'

COMMIT = false
INPUT = Input!
STATE = State!
SESSION = Session scriptfile

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
love.textinput     = INPUT\textinput
love.mousemoved    = INPUT\mousemoved
love.mousepressed  = INPUT\mousepressed
love.mousereleased = INPUT\mousereleased
