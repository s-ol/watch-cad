utf8 = require 'utf8'
import vec2 from require 'cpml'

class Input
  NON_TEXT_KEYS = {k,true for k in *{'escape', 'return', 'clear'}}
  new: =>
    @last_keys = {}
    @keys = {}

    @last_mouse = vec2!
    @mouse = @last_mouse\clone!

    @text = nil

  mouse_down:  (button=1) => @key_down "mouse-#{button}"
  mouse_up:    (button=1) => @key_up   "mouse-#{button}"
  mouse_held:  (button=1) => @key_held "mouse-#{button}"
  mouse_event: (button=1) => (@key_event "mouse-#{button}") or 'hover'

  key_down: (key) => @keys[key] and not @last_keys[key]
  key_up:   (key) => not @keys[key] and @last_keys[key]
  key_held: (key) => @keys[key]
  key_event: (key) =>
    return 'down' if @key_down key
    return 'up'   if @key_up   key
    return 'held' if @key_held key

  text_capture: =>
    assert not @text, "keyboard already captured!"
    @text = ''

  text_release: =>
    with @text
      @text = nil

  mouse_pos: => @mouse
  mouse_delta: => @mouse - @last_mouse

  keyreleased: (key) => @keys[key] = nil
  keypressed:  (key) =>
    if @text and not NON_TEXT_KEYS[key]
      @textinput nil, key
      return

    @keys[key] = true

  textinput: (str, key) =>
    return unless @text
    if str
      @text ..= str
    else
      switch key
        when 'backspace'
          offset = utf8.offset @text, -1
          @text = string.sub @text, 1, offset - 1 if offset

  mousemoved: (x, y) => @mouse.x, @mouse.y = x, y
  mousepressed:  (_, _, button) => @keys["mouse-#{button}"] = true
  mousereleased: (_, _, button) => @keys["mouse-#{button}"] = nil

  frame: =>
    @last_mouse = @mouse
    @mouse = @mouse\clone!

    @last_keys = @keys
    @keys = {k,v for k,v in pairs @keys}

{
  :Input
}
