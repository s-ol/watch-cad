import vec2 from require 'cpml'

=>
  a = input.point @point, x: 200
  rect = input.rectangle @rect, min: a + (vec2 30, 0), max: { y: 200 }

  circle = input.circle @circ, center: rect.min, tangent: rect.max
