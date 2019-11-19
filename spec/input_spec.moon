import Input from require 'input'
import vec2 from require 'cpml'

describe "Input", ->
  input = Input!

  it "sane initial state", ->
    assert.is_equal vec2!, input\mouse_delta!
    assert.is_falsy input\mouse_down!
    assert.is_falsy input\mouse_up!
    assert.is_falsy input\mouse_held!
    assert.is_equal 'hover', input\mouse_event!
    assert.is_falsy input\key_down  'w'
    assert.is_falsy input\key_up    'w'
    assert.is_falsy input\key_held  'w'
    assert.is_falsy input\key_event 'w'

  it "processes input events", ->
    input\mousemoved 0, 0
    input\frame!
    input\mousemoved 20, 20
    input\keypressed 'w'
    input\keypressed 'a'
    input\mousepressed 21, 21, 1
    input\mousepressed 21, 21, 2

  it "updates accordingly", ->
    assert.is_equal (vec2 20, 20), input.mouse
    assert.is_equal (vec2 20, 20), input\mouse_pos!
    assert.is_equal (vec2 20, 20), input\mouse_delta!

    assert.is_true  input\mouse_down!
    assert.is_true  input\mouse_held!
    assert.is_falsy input\mouse_up!
    assert.is_equal 'down', input\mouse_event!

    assert.is_true  input\mouse_down 2
    assert.is_true  input\mouse_held 2
    assert.is_falsy input\mouse_up   2
    assert.is_equal 'down', input\mouse_event 2

    assert.is_true  input\key_down 'w'
    assert.is_true  input\key_held 'w'
    assert.is_falsy input\key_up   'w'
    assert.is_equal 'down', input\key_event 'w'

  it "keep state after end-of-frame", ->
    input\frame!

    assert.is_equal (vec2 20, 20), input.mouse
    assert.is_equal (vec2 20, 20), input\mouse_pos!
    assert.is_equal vec2!,         input\mouse_delta!

    assert.is_true  input\mouse_held!
    assert.is_falsy input\mouse_down!
    assert.is_falsy input\mouse_up!
    assert.is_equal 'held', input\mouse_event!

    assert.is_true  input\mouse_held 2
    assert.is_falsy input\mouse_down 2
    assert.is_falsy input\mouse_up   2
    assert.is_equal 'held', input\mouse_event 2

    assert.is_true  input\key_held 'w'
    assert.is_falsy input\key_down 'w'
    assert.is_falsy input\key_up   'w'
    assert.is_equal 'held', input\key_event 'w'

  it "keeps updating", ->
    input\keyreleased 'a'
    input\mousereleased 21, 21, 2
    input\mousemoved 0, 40

    assert.is_equal (vec2 0, 40),   input.mouse
    assert.is_equal (vec2 0, 40),   input\mouse_pos!
    assert.is_equal (vec2 -20, 20), input\mouse_delta!

    assert.is_true  input\mouse_held!
    assert.is_falsy input\mouse_down!
    assert.is_falsy input\mouse_up!
    assert.is_equal 'held', input\mouse_event!

    assert.is_true  input\mouse_up   2
    assert.is_falsy input\mouse_held 2
    assert.is_falsy input\mouse_down 2
    assert.is_equal 'up', input\mouse_event 2

    assert.is_true  input\key_held 'w'
    assert.is_falsy input\key_down 'w'
    assert.is_falsy input\key_up   'w'
    assert.is_equal 'held', input\key_event 'w'

    assert.is_true  input\key_up   'a'
    assert.is_falsy input\key_held 'a'
    assert.is_falsy input\key_down 'a'
    assert.is_equal 'up', input\key_event 'a'

  it "allows capturing the keyboard", ->
    input\text_capture!
    assert.has_error -> input\text_capture!

    input\textinput 'Helloo'
    input\keypressed 'backspace'
    assert.is_falsy input\key_down 'backspace'
    input\frame!

    assert.is_equal 'Hello', input.text
    input\textinput ' World'
    assert.is_equal 'Hello World', input.text
    assert.is_falsy input\key_down 'backspace'

  it "doesn't capture meta-keys (return and escape)", ->
    input\keypressed 'return'
    input\keypressed 'escape'

    assert.is_true input\key_down 'return'
    assert.is_true input\key_down 'escape'

  it "returns the input' text after releasing the keyboard", ->
    assert.is_equal 'Hello World', input\text_release!

    input\keypressed 'backspace'
    assert.is_true input\key_down 'backspace'
