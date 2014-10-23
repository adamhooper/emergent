_ = require('lodash')

# Represents a curve (function) passing through multiple points.
#
#   # Create it using (x,y) coordinates
#   curve = new MultiPointCurve([[1,2], [2,3], [3,4]])
#   # Find a y value for the given x
#   curve.yAt(1.5) # 2.5
#   # Find original points
#   curve.xyAtOrBefore(1.5) # [ 1, 2 ]
#   curve.xyAtOrAfter(1.5) # [ 2, 3 ]
module.exports = class MultiPointCurve
  constructor: (@points) ->
    @_xs = (p[0] for p in @points)

  yAt: (x) ->
    p1 = @xyAtOrBefore(x)
    p2 = @xyAtOrAfter(x)

    if !p1? || !p2?
      null
    else if p1 == p2
      p1[1]
    else
      x1 = p1[0]
      x2 = p2[0]
      y1 = p1[1]
      y2 = p2[1]

      y1 + (y2 - y1) * (x - x1) / (x2 - x1)

  xyAtOrBefore: (x) ->
    i = _.sortedIndex(@_xs, x)

    if i < @points.length && @points[i][0] == x
      @points[i]
    else if i == 0
      null
    else
      @points[i - 1]

  xyAtOrAfter: (x) ->
    i = _.sortedIndex(@_xs, x)

    if i < @points.length && @points[i][0] == x
      @points[i]
    else if i == @points.length
      null
    else
      @points[i]
