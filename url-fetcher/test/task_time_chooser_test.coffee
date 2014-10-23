TaskTimeChooser = require('../lib/task_time_chooser')

describe 'TaskTimeChooser', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @sandbox.clock.tick(1000)
    @subject = new TaskTimeChooser(delays: [ 0, 3000, 2000, 1000 ])

  afterEach ->
    @sandbox.restore()

  it 'should choose right now when there is no previous time', ->
    expect(@subject.chooseTime(0, null)).to.deep.eq(new Date(1000))

  it 'should choose the correct future time', ->
    expect(@subject.chooseTime(1, new Date(500))).to.deep.eq(new Date(3500))

  it 'should not be cumulative', ->
    expect(@subject.chooseTime(2, new Date(500))).to.deep.eq(new Date(2500))

  it 'should return null when there is nothing more to do', ->
    expect(@subject.chooseTime(4, new Date(500))).to.be.null
