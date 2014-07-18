Startup = require('../lib/startup')
Promise = require('bluebird')
models = require('../../data-store/lib/models')

Url = models.Url

describe 'startup', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @clock = @sandbox.clock
  afterEach ->
    @sandbox.restore()

  beforeEach ->
    @sandbox.stub(Url, 'findAllRaw')

    @queue =
      queue: sinon.spy()

    @startup = new Startup(queue: @queue)

  it 'should run a callback', (done) ->
    Url.findAllRaw.returns(Promise.resolve([]))
    @startup.run (err) ->
      expect(err).to.be.null
      done()

  it 'should search for URLs', (done) ->
    Url.findAllRaw.returns(Promise.resolve([]))
    @startup.run (err) =>
      expect(Url.findAllRaw).to.have.been.called
      done()

  it 'should error when URLs cannot be searched', (done) ->
    Url.findAllRaw.returns(Promise.reject('err'))
    @startup.run (err) ->
      expect(err).to.equal('err')
      done()

  describe 'with some urls', ->
    beforeEach ->
      @foundUrls = []
      Url.findAllRaw.returns(Promise.resolve(@foundUrls))

    it 'should schedule immediate fetch, facebook, google and twitter jobs', (done) ->
      @foundUrls.push(id: 'abcdef', url: 'https://example.org')
      @startup.run =>
        expect(@queue.queue).to.have.been.calledWith('fetch', 'abcdef', 'https://example.org', new Date())
        expect(@queue.queue).to.have.been.calledWith('google', 'abcdef', 'https://example.org', new Date())
        expect(@queue.queue).to.have.been.calledWith('facebook', 'abcdef', 'https://example.org', new Date())
        expect(@queue.queue).to.have.been.calledWith('twitter', 'abcdef', 'https://example.org', new Date())
        done()

    it 'should schedule a second fetch a few milliseconds later', (done) ->
      @foundUrls.push(id: 'abcdef', url: 'https://example.org')
      @foundUrls.push(id: 'ghijkl', url: 'https://example.com')
      @startup.run =>
        expect(@queue.queue).to.have.been.calledWith('fetch', 'ghijkl', 'https://example.com', new Date(619))
        expect(@queue.queue).to.have.been.calledWith('google', 'ghijkl', 'https://example.com', new Date(619))
        expect(@queue.queue).to.have.been.calledWith('facebook', 'ghijkl', 'https://example.com', new Date(619))
        expect(@queue.queue).to.have.been.calledWith('twitter', 'ghijkl', 'https://example.com', new Date(619))
        done()

