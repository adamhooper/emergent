MultiPointCurve = require('../lib/multi_point_curve')

describe 'multi_point_curve', ->
  describe 'with a basic curve', ->
    beforeEach ->
      @subject = new MultiPointCurve([ [ 10, 15 ], [ 20, 25 ], [ 30, 20 ] ])

    describe '#yAt', ->
      it 'should interpolate between points', ->
        expect(@subject.yAt(11)).to.eq(16)
        expect(@subject.yAt(22)).to.eq(24)

      it 'should give y values at exact points', ->
        expect(@subject.yAt(10)).to.eq(15)
        expect(@subject.yAt(20)).to.eq(25)
        expect(@subject.yAt(30)).to.eq(20)

      it 'should give null to the left of the first point', ->
        expect(@subject.yAt(9)).to.be.null

      it 'should give null to the right of the last point', ->
        expect(@subject.yAt(31)).to.be.null

    describe '#xyAtOrBefore', ->
      it 'should find the correct xy from between points', ->
        expect(@subject.xyAtOrBefore(11)).to.deep.eq([ 10, 15 ])
        expect(@subject.xyAtOrBefore(19)).to.deep.eq([ 10, 15 ])
        expect(@subject.xyAtOrBefore(21)).to.deep.eq([ 20, 25 ])

      it 'should find the correct xy from exact points', ->
        expect(@subject.xyAtOrBefore(10)).to.deep.eq([ 10, 15 ])
        expect(@subject.xyAtOrBefore(20)).to.deep.eq([ 20, 25 ])
        expect(@subject.xyAtOrBefore(30)).to.deep.eq([ 30, 20 ])

      it 'should find the last point when to the right of it', ->
        expect(@subject.xyAtOrBefore(31)).to.deep.eq([ 30, 20 ])

      it 'should find null to the left of the first point', ->
        expect(@subject.xyAtOrBefore(9)).to.be.null

    describe '#xyAtOrAfter', ->
      it 'should find the correct xy from between points', ->
        expect(@subject.xyAtOrAfter(11)).to.deep.eq([ 20, 25 ])
        expect(@subject.xyAtOrAfter(19)).to.deep.eq([ 20, 25 ])
        expect(@subject.xyAtOrAfter(21)).to.deep.eq([ 30, 20 ])

      it 'should find the correct xy from exact points', ->
        expect(@subject.xyAtOrAfter(10)).to.deep.eq([ 10, 15 ])
        expect(@subject.xyAtOrAfter(20)).to.deep.eq([ 20, 25 ])
        expect(@subject.xyAtOrAfter(30)).to.deep.eq([ 30, 20 ])

      it 'should find null to the right of the last point', ->
        expect(@subject.xyAtOrAfter(31)).to.be.null

      it 'should find the first point when to the left of it', ->
        expect(@subject.xyAtOrAfter(9)).to.deep.eq([ 10, 15 ])
