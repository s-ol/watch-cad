class State
  @mt: {
    __index: (t, k) ->
      with v = setmetatable {}, @@mt
        rawset t, k, v
  }

  new: =>
    @reset!

  reset: =>
    @state = setmetatable {}, @@mt

{
  :State
}
