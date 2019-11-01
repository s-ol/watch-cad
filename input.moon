import vec2 from require 'cpml'

class Input
  new: =>
    @last_keys = {}
    @keys = {}

    @mouse = vec2 love.mouse.getPosition!
    @last_mouse = @mouse\clone!

  mouse_down: (button=1) => @key_down "mouse-#{button}"
  mouse_up:   (button=1) => @key_up   "mouse-#{button}"
  mouse_held: (button=1) => @key_held "mouse-#{button}"

  mouse_event: (button=1) =>
    return 'down' if @mouse_down button
    return 'up'   if @mouse_up   button
    return 'held' if @mouse_held button

  key_down: (key) => @keys[key] and not @last_keys[key]
  key_up:   (key) => not @keys[key] and @last_keys[key]
  key_held: (key) => @keys[key]

  mouse_pos: => @mouse
  mouse_delta: => @mouse - @last_mouse

  keypressed:  (key) => @keys[key] = true
  keyreleased: (key) => @keys[key] = nil

  mousepressed:  (_, _, button) => @keys["mouse-#{button}"] = true
  mousereleased: (_, _, button) => @keys["mouse-#{button}"] = nil

  end_frame: =>
    @last_mouse = @mouse
    @mouse = vec2 love.mouse.getPosition!

    @last_keys = @keys
    @keys = {k,v for k,v in pairs @keys}

{
  :Input
}
