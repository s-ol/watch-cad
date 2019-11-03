-- let's load a vector library for doing some
-- more interesting transformations

import vec2 from require 'cpml'

=>
  -- let's try to construct a pill-shape
  input.rectangle @rect
  rect = @rect!
  hsize = (rect.max - rect.min) / 2

  input.circle @left, {
    center: rect.min + vec2 0, hsize.y
    radius: hsize.y
  }
  input.circle @left, {
    center: rect.min + vec2 hsize.x*2, hsize.y
    radius: hsize.y
  }

  -- right, so that's that....
  -- kinda forgetting whether there was something
  -- else I wanted to show.
  -- does this seem interesting to you?
  -- let me know :)
