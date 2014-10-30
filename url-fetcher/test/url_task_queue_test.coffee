UrlTaskQueue = require('../lib/url_task_queue')

describe 'UrlTaskQueue', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)

    @task = sinon.spy()
    @log = sinon.spy()

    # example IDs in order: this is how the queue will tie-break
    @id1 = '1e0d9960-6892-4555-9e4d-40469b4bc92b'
    @id2 = 'ba8e0822-9eb2-461c-8aaf-e2e0a0ac93fd'
    @id3 = 'e452f537-c189-4ab3-a6e4-e803a9527eb7'

    @queue = new UrlTaskQueue
      task: @task
      log: @log
      throttleMs: 123

    @doQueue = (urlId, url, at) =>
      @queue.queue
        urlId: urlId
        url: url
        at: at
        nPreviousFetches: 0

    @expectLastCall = (urlId, url) =>
      expect(@task).to.have.been.calledWith(@queue)
      job = @task.lastCall.args[1]
      expect(job).to.have.property('urlId', urlId)
      expect(job).to.have.property('url', url)

  afterEach ->
    @queue.stopHandling()
    @sandbox.restore()

  it 'should run a task on start', ->
    @doQueue(@id1, 'http://example.org', new Date())
    @queue.startHandling()
    @sandbox.clock.tick(1)
    @expectLastCall(@id1, 'http://example.org')

  it 'should throttle multiple tasks', ->
    # Set the dates in order: if all are set for the same time, then the
    # priority queue could return 3 before 2.
    @doQueue(@id1, 'http://example.org/1', new Date(0))
    @doQueue(@id2, 'http://example.org/2', new Date(1))
    @doQueue(@id3, 'http://example.org/3', new Date(2))
    @queue.startHandling()
    @sandbox.clock.tick(122)
    @expectLastCall(@id1, 'http://example.org/1') # not 2 or 3
    @sandbox.clock.tick(1)
    @expectLastCall(@id2, 'http://example.org/2')
    @sandbox.clock.tick(122)
    @expectLastCall(@id2, 'http://example.org/2') # not 3
    @sandbox.clock.tick(1)
    @expectLastCall(@id3, 'http://example.org/3')

  it 'should run tasks in the future', ->
    @doQueue(@id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
    @queue.startHandling()
    @sandbox.clock.tick(999)
    expect(@task).not.to.have.been.called
    @sandbox.clock.tick(1)
    @expectLastCall(@id1, 'http://example.org')

  it 'should run a task later than the throttle delay', ->
    @doQueue(@id1, 'http://example.org/1', new Date())
    @doQueue(@id2, 'http://example.org/2', new Date(124))
    @queue.startHandling()
    @sandbox.clock.tick(123)
    @expectLastCall(@id1, 'http://example.org/1') # not 2
    @sandbox.clock.tick(1)
    @expectLastCall(@id2, 'http://example.org/2')

  it 'should run tasks in order', ->
    @doQueue(@id1, 'http://example.org/1', new Date(new Date().valueOf() + 1000))
    @doQueue(@id3, 'http://example.org/3', new Date(new Date().valueOf() + 3000))
    @doQueue(@id2, 'http://example.org/2', new Date(new Date().valueOf() + 2000))
    @queue.startHandling()
    @sandbox.clock.tick(1000)
    @expectLastCall(@id1, 'http://example.org/1')
    @sandbox.clock.tick(1000)
    @expectLastCall(@id2, 'http://example.org/2')
    @sandbox.clock.tick(1000)
    @expectLastCall(@id3, 'http://example.org/3')

  describe 'when started empty', ->
    beforeEach -> @queue.startHandling()

    it 'should run a task immediately', ->
      @doQueue(@id1, 'http://example.org', new Date())
      @sandbox.clock.tick(1)
      @expectLastCall(@id1, 'http://example.org')

    it 'should schedule a task for later', ->
      @doQueue(@id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(999)
      expect(@task).not.to.have.been.called
      @sandbox.clock.tick(1)
      @expectLastCall(@id1, 'http://example.org')

    it 'should schedule a sooner task before the queued one', ->
      t1 = new Date().valueOf()

      @doQueue(@id1, 'http://example.org/1', new Date(t1 + 1000))
      @sandbox.clock.tick(500)
      @doQueue(@id2, 'http://example.org/2', new Date(t1 + 750))
      @sandbox.clock.tick(249)
      expect(@task).not.to.have.been.calledWith(@queue)
      @sandbox.clock.tick(1)
      @expectLastCall(@id2, 'http://example.org/2')
      @sandbox.clock.tick(250)
      @expectLastCall(@id1, 'http://example.org/1')

    it 'should do nothing when stopped', ->
      @doQueue(@id1, 'http://example.org', new Date(new Date().valueOf() + 1000))
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
      @doQueue(@id1, 'http://example.org/1', new Date(new Date().valueOf() + 1000))
      @sandbox.clock.tick(1000)
      @task.lastCall.args[0].queue(urlId: @id2, url: 'http://example.org/2', at: new Date(new Date().valueOf() + 1000), nPreviousFetches: 1)
      @sandbox.clock.tick(999)
      @expectLastCall(@id1, 'http://example.org/1') # id2 wasn't called yet
      @sandbox.clock.tick(1)
      @expectLastCall(@id2, 'http://example.org/2')
