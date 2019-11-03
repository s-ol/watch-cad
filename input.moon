import vec2 from require 'cpml'

class Input
  new: =>
    @last_keys = {}
    @keys = {}

    @last_mouse = vec2!
    @mouse = @last_mouse\clone!

  mouse_down:  (button=1) => @key_down "mouse-#{button}"
  mouse_up:    (button=1) => @key_up   "mouse-#{button}"
  mouse_held:  (button=1) => @key_held "mouse-#{button}"
  mouse_event: (button=1) => @key_event "mouse-#{button}"

  key_down: (key) => @keys[key] and not @last_keys[key]
  key_up:   (key) => not @keys[key] and @last_keys[key]
  key_held: (key) => @keys[key]
  key_event: (key) =>
    return 'down' if @key_down key
    return 'up'   if @key_up   key
    return 'held' if @key_held key

  mouse_pos: => @mouse
  mouse_delta: => @mouse - @last_mouse

  keypressed:  (key) => @keys[key] = true
  keyreleased: (key) => @keys[key] = nil

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
