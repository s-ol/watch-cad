unpack = unpack or table.unpack

class Once
  new: (@value) =>

  @is_once: (val) ->
    return false unless val
    return false unless 'table' == type val
    val.__class == @@

is_once = (val) -> (Once.is_once val) and val.value
is_live = (val) -> (not Once.is_once val) and val

class Cursor
  @__base.__index = do
    old_index = @__base.__index
    (k) =>
      if v = old_index[k]
        return v

      if 'string' == type k
        return @get_nested k

  new: (@state, @path='') =>

  set: (value) =>
    @state.values[@path] = value
    value

  get: (value) =>
    @state.values[@path]

  init: (value) =>
    old = @get!
    if old != nil
      old
    else
      @set value

  drive: (live_or_once) =>
    if val = is_once live_or_once
      @init val
    else
      @set live_or_once

  get_nested: (name) =>
    if #@path > 0
      name = "#{@path}.#{name}"

    Cursor @state, name

  __call: => @get!
  __tostring: => @path
  __eq: (other) => @path == other.path

  @is_cursor: (val) ->
    return false unless val
    return false unless 'table' == type val
    val.__class == @@

class State
  @mt: {
    __index: (t, k) ->
      if v = @[k]
        return v

      with v = setmetatable {}, @@mt
        rawset t, k, v
  }

  -- initialize state under 'key' with 'default' unless already set
  init: (key, default) =>
    if val = is_once default
      default = val
    rawset @, key, (rawget @, key) or default

  new: =>
    @reset!

  reset: =>
    @values = setmetatable {}, {
      __index: (k) =>
        if Cursor.is_cursor k
          k = tostring k
        rawget @, k
      __newindex: (k, v) =>
        if Cursor.is_cursor k
          k = tostring k
        rawset @, k, v
    }
    @root = Cursor @

{
  :is_once
  :is_live
  :Once
  :Cursor
  :State
}
