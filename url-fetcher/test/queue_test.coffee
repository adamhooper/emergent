UrlQueue = require('../lib/queue')

describe 'queue', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)

    @handler1 = sinon.stub()
    @handler2 = sinon.stub()
    @handlers =
      type1: (args...) => @handler1(args...)
      type2: (args...) => @handler2(args...)

    @id1 = '1e0d9960-6892-4555-9e4d-40469b4bc92b'
    @id2 = 'e452f537-c189-4ab3-a6e4-e803a9527eb7'
    @id3 = 'ba8e0822-9eb2-461c-8aaf-e2e0a0ac93fd'

    @queue = new UrlQueue
      handlers: @handlers

  afterEach ->
    @queue.stopHandling()

  it 'should run a job when started', ->
    @queue.queue('type1', @id1, 'http://example.org', new Date())
    @queue.startHandling()
    @sandbox.clock.tick(1)
    expect(@handler1).to.have.been.calledWith(@id1, 'http://example.org')

  it 'should run all jobs when starting', ->
    @queue.queue('type1', @id1, 'http://example.org', new Date())
    @queue.queue('type2', @id2, 'http://example.com', new Date())
    @queue.startHandling()
    @sandbox.clock.tick(1)
    expect(@handler1).to.have.been.calledWith(@id1, 'http://example.org')
    expect(@handler2).to.have.been.calledWith(@id2, 'http://example.com')

  it 'should run jobs later', ->
    @queue.queue('type1', @id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
    @queue.startHandling()
    @sandbox.clock.tick(999)
    expect(@handler1).not.to.have.been.called
    @sandbox.clock.tick(1)
    expect(@handler1).to.have.been.calledWith(@id1, 'http://example.org')

  it 'should run jobs in order', ->
    @queue.queue('type1', @id1, 'http://example.org/1', new Date(new Date().valueOf() + 1000))
    @queue.queue('type1', @id3, 'http://example.org/3', new Date(new Date().valueOf() + 3000))
    @queue.queue('type1', @id2, 'http://example.org/2', new Date(new Date().valueOf() + 2000))
    @queue.startHandling()
    @sandbox.clock.tick(1000)
    expect(@handler1).to.have.been.calledWith(@id1, 'http://example.org/1')
    expect(@handler1).not.to.have.been.calledWith(@id2, 'http://example.org/2')
    expect(@handler1).not.to.have.been.calledWith(@id3, 'http://example.org/3')
    @sandbox.clock.tick(1000)
    expect(@handler1).to.have.been.calledWith(@id2, 'http://example.org/2')
    expect(@handler1).not.to.have.been.calledWith(@id3, 'http://example.org/3')
    @sandbox.clock.tick(1000)
    expect(@handler1).to.have.been.calledWith(@id3, 'http://example.org/3')

  describe 'when started empty', ->
    beforeEach -> @queue.startHandling()

    it 'should run a job immediately', ->
      @queue.queue('type1', @id1, 'http://example.org', new Date())
      @sandbox.clock.tick(1)
      expect(@handler1).to.have.been.calledWith(@id1, 'http://example.org')

    it 'should schedule a job for later', ->
      @queue.queue('type1', @id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(999)
      expect(@handler1).not.to.have.been.called
      @sandbox.clock.tick(1)
      expect(@handler1).to.have.been.calledWith(@id1, 'http://example.org')

    it 'should schedule a sooner job before the queued one', ->
      t1 = new Date().valueOf()

      @queue.queue('type1', @id1, 'http://example.org', new Date(t1 + 1000))
      @sandbox.clock.tick(500)
      @queue.queue('type2', @id2, 'http://example.org', new Date(t1 + 750))
      @sandbox.clock.tick(249)
      expect(@handler1).not.to.have.been.called
      expect(@handler2).not.to.have.been.called
      @sandbox.clock.tick(1)
      expect(@handler1).not.to.have.been.called
      expect(@handler2).to.have.been.called
      @sandbox.clock.tick(250)
      expect(@handler1).to.have.been.called

    it 'should run a job with no "at" as if it has the current time', ->
      @queue.queue('type1', @id1, 'http://example.org', new Date())
      @queue.queue('type2', @id2, 'http://example.org')
      @sandbox.clock.tick(1)
      expect(@handler1).to.have.been.calledBefore(@handler2)

    it 'should do nothing when stopped', ->
      @queue.queue('type1', @id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(999)
      @queue.stopHandling()
      @sandbox.clock.tick(1)
      expect(@handler1).not.to.have.been.called
      @queue.startHandling()
      @sandbox.clock.tick(1)
      expect(@handler1).to.have.been.called

    it 'should let a handler queue something', ->
      # Not sure why this would ever fail if the others pass ... but it should
      # inspire confidence because this is how we're going to use it.
      @handlers.type1 = (args...) =>
        @queue.queue('type2', @id2, 'http://example.org/2', new Date(new Date().valueOf() + 1000))
        @handler1(args...)
      @queue.queue('type1', @id1, 'http://example.org/1', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(1000)
      expect(@handler1).to.have.been.calledWith(@id1, 'http://example.org/1')
      @sandbox.clock.tick(999)
      expect(@handler2).not.to.have.been.called
      @sandbox.clock.tick(1)
      expect(@handler2).to.have.been.calledWith(@id2, 'http://example.org/2')
