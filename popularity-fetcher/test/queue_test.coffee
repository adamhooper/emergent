Queue = require('../lib/queue')

describe 'queue', ->
  beforeEach ->
    @kueQueue =
      createJob: sinon.stub()

    @queue = new Queue(@kueQueue)

    @job =
      save: sinon.stub().callsArgWith(0, null, {})
    @job.delay = sinon.stub().returns(@job)

    @kueQueue.createJob.returns(@job)

  it 'should push jobs to kue', (done) ->
    @queue.push 'facebook', 'abcdef', (err) =>
      expect(err).to.be.null
      expect(@kueQueue.createJob).to.have.been.calledWith('url', { service: 'facebook', urlId: 'abcdef' })
      expect(@job.delay).not.to.have.been.called
      expect(@job.save).to.have.been.called
      done()

  it 'should call .str on a real ObjectId', (done) ->
    @queue.push 'facebook', { str: 'abcdef' }, (err) =>
      expect(@kueQueue.createJob).to.have.been.calledWith('url', { service: 'facebook', urlId: 'abcdef' })
      done()

  it 'should error when save errors', (done) ->
    @job.save.callsArgWith(0, 'err')
    @queue.push 'facebook', 'abcdef', (err) =>
      expect(err).to.equal('err')
      done()

  it 'should push delayed jobs to kue', (done) ->
    @queue.pushWithDelay 'facebook', 'abcdef', 3000, (err) =>
      expect(err).to.be.null
      expect(@kueQueue.createJob).to.have.been.calledWith('url', { service: 'facebook', urlId: 'abcdef' })
      expect(@job.delay).to.have.been.calledWith(3000)
      expect(@job.save).to.have.been.called
      done()

  it 'should error when save delayed errors', (done) ->
    @job.save.callsArgWith(0, 'err')
    @queue.pushWithDelay 'facebook', 'abcdef', 3000, (err) ->
      expect(err).to.equal('err')
      done()
