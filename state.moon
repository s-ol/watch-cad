unpack = unpack or table.unpack

class Once
  new: (@value) =>

  @is_once: (val) ->
    return unless val
    return unless 'table' == type val
    val.__class == @@

all = (f) -> (...) ->
  values = for i = 1, select '#', ...
    val = f select i, ...
    return unless val
    val

  unpack values

is_once = (val) -> (Once.is_once val) and val.value
is_live = (val) -> (not is_once val) and val

are_once = all is_once
are_live = all is_live

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

  -- store and return a piece of state under 'key'.
  -- the current and stored value is the first of the following:
  -- * 'fixed', if it is a 'live' value
  -- * current state, if set
  -- * 'fixed', if it is a 'once' value
  -- * 'default'
  store: (key, fixed, default) =>
    state = rawget @, key
    once = Once.is_once fixed

    next_state = if is_live fixed
      fixed
    elseif state
      state
    elseif once
      fixed.value
    else
      default

    with next_state
      rawset @, key, next_state

  new: =>
    @reset!

  reset: =>
    @state = setmetatable {}, @@mt

{
  :is_once, :are_once
  :is_live, :are_live
  :Once
  :State
}
