import vec2 from require 'cpml'
-- import random, hit, draw from require 'api'

class Object
  new: (@pos=random.point!, @size=random.size!) =>

  copy: => Object @pos, @size

  minmax: =>
    @pos - @size/2, @pos + @size/2

  hit: =>
    hit.rect @minmax!

  draw: =>
    draw.rect @minmax!

{
  :Object
}
