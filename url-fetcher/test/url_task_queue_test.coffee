UrlTaskQueue = require('../lib/url_task_queue')

describe 'UrlTaskQueue', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)

    @task = sinon.spy()
    @log = sinon.spy()

    @id1 = '1e0d9960-6892-4555-9e4d-40469b4bc92b'
    @id2 = 'e452f537-c189-4ab3-a6e4-e803a9527eb7'
    @id3 = 'ba8e0822-9eb2-461c-8aaf-e2e0a0ac93fd'

    @queue = new UrlTaskQueue
      task: @task
      log: @log

  afterEach ->
    @queue.stopHandling()
    @sandbox.restore()

  it 'should run a tasks on start', ->
    @queue.queue(@id1, 'http://example.org', new Date())
    @queue.startHandling()
    @sandbox.clock.tick(1)
    expect(@task).to.have.been.calledWith(@queue, @id1, 'http://example.org')

  it 'should run all tasks on start', ->
    @queue.queue(@id1, 'http://example.org', new Date())
    @queue.queue(@id2, 'http://example.com', new Date())
    @queue.startHandling()
    @sandbox.clock.tick(1)
    expect(@task).to.have.been.calledWith(@queue, @id1, 'http://example.org')
    expect(@task).to.have.been.calledWith(@queue, @id2, 'http://example.com')

  it 'should run tasks later', ->
    @queue.queue(@id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
    @queue.startHandling()
    @sandbox.clock.tick(999)
    expect(@task).not.to.have.been.called
    @sandbox.clock.tick(1)
    expect(@task).to.have.been.calledWith(@queue, @id1, 'http://example.org')

  it 'should run tasks in order', ->
    @queue.queue(@id1, 'http://example.org/1', new Date(new Date().valueOf() + 1000))
    @queue.queue(@id3, 'http://example.org/3', new Date(new Date().valueOf() + 3000))
    @queue.queue(@id2, 'http://example.org/2', new Date(new Date().valueOf() + 2000))
    @queue.startHandling()
    @sandbox.clock.tick(1000)
    expect(@task).to.have.been.calledWith(@queue, @id1, 'http://example.org/1')
    expect(@task).not.to.have.been.calledWith(@queue, @id2, 'http://example.org/2')
    expect(@task).not.to.have.been.calledWith(@queue, @id3, 'http://example.org/3')
    @sandbox.clock.tick(1000)
    expect(@task).to.have.been.calledWith(@queue, @id2, 'http://example.org/2')
    expect(@task).not.to.have.been.calledWith(@queue, @id3, 'http://example.org/3')
    @sandbox.clock.tick(1000)
    expect(@task).to.have.been.calledWith(@queue, @id3, 'http://example.org/3')

  describe 'when started empty', ->
    beforeEach -> @queue.startHandling()

    it 'should run a task immediately', ->
      @queue.queue(@id1, 'http://example.org', new Date())
      @sandbox.clock.tick(1)
      expect(@task).to.have.been.calledWith(@queue, @id1, 'http://example.org')

    it 'should schedule a task for later', ->
      @queue.queue(@id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(999)
      expect(@task).not.to.have.been.called
      @sandbox.clock.tick(1)
      expect(@task).to.have.been.calledWith(@queue, @id1, 'http://example.org')

    it 'should schedule a sooner task before the queued one', ->
      t1 = new Date().valueOf()

      @queue.queue(@id1, 'http://example.org', new Date(t1 + 1000))
      @sandbox.clock.tick(500)
      @queue.queue(@id2, 'http://example.org', new Date(t1 + 750))
      @sandbox.clock.tick(249)
      expect(@task).not.to.have.been.calledWith(@queue, @id1)
      expect(@task).not.to.have.been.calledWith(@queue, @id2)
      @sandbox.clock.tick(1)
      expect(@task).not.to.have.been.calledWith(@queue, @id1)
      expect(@task).to.have.been.calledWith(@queue, @id2)
      @sandbox.clock.tick(250)
      expect(@task).to.have.been.calledWith(@queue, @id1)

    it 'should do nothing when stopped', ->
      @queue.queue(@id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(999)
      @queue.stopHandling()
      @sandbox.clock.tick(1)
      expect(@task).not.to.have.been.called
      @queue.startHandling()
      @sandbox.clock.tick(1)
      expect(@task).to.have.been.called

    it 'should let a handler queue something', ->
      # Not sure why this would ever fail if the others pass ... but it should
      # inspire confidence because this is how we're going to use it.
      @queue.queue(@id1, 'http://example.org/1', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(1000)
      @task.lastCall.args[0].queue(@id2, 'http://example.org/2', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(999)
      expect(@queue.task).not.to.have.been.calledWith(@queue, @id2, 'http://example.org/2')
      @sandbox.clock.tick(1)
      expect(@queue.task).to.have.been.calledWith(@queue, @id2, 'http://example.org/2')
