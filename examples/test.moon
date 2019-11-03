import vec2 from require 'cpml'

=>
  input.point @p

  input.rectangle @re, max: @p!

  input.circle @circ, center: @p!
