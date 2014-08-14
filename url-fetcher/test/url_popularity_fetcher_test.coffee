UrlPopularityFetcher = require('../lib/url_popularity_fetcher')
Promise = require('bluebird')
models = require('../../data-store').models

UrlPopularityGet = models.UrlPopularityGet

describe 'url_popularity_fetcher', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @sandbox.stub(UrlPopularityGet, 'create').returns(Promise.resolve(null))

    @queues =
      facebook: { queue: sinon.spy() }
      twitter: { queue: sinon.spy() }
      google: { queue: sinon.spy() }

    @fetchLogic =
      facebook: sinon.stub().callsArgWith(1, null, { n: 10, rawData: { foo: 'bar' }})

    @fetcher = new UrlPopularityFetcher
      queues: @queues
      fetchLogic: @fetchLogic

  afterEach ->
    @sandbox.restore()

  it 'should call the appropriate fetch logic', (done) ->
    @fetcher.fetch 'facebook', '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', =>
      expect(@fetchLogic.facebook).to.have.been.calledWith('http://example.org')
      done()

  it 'should error when the fetch logic errors', (done) ->
    @fetchLogic.facebook.callsArgWith(1, 'err')
    @fetcher.fetch 'facebook', '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', (err) =>
      expect(err.message).to.equal('err')
      done()

  it 'should create a UrlPopularityGet', (done) ->
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch 'facebook', id, 'http://example.org', =>
      expect(UrlPopularityGet.create).to.have.been.calledWith(urlId: id, shares: 10, service: 'facebook', rawData: { foo: 'bar' })
      done()

  it 'should error when the urlFetches insertion errors', (done) ->
    UrlPopularityGet.create.returns(Promise.reject('err'))
    @fetcher.fetch 'facebook', '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should queue another fetch in two hours on success', (done) ->
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch 'facebook', id, 'http://example.org', =>
      expect(@queues.facebook.queue).to.have.been.calledWith(id, 'http://example.org', new Date(2 * 3600 * 1000))
      expect(@queues.twitter.queue).not.to.have.been.called
      expect(@queues.google.queue).not.to.have.been.called
      done()

  it 'should queue another fetch in two hours on fetching error', (done) ->
    @fetchLogic.facebook.callsArgWith(1, 'err')
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch 'facebook', id, 'http://example.org', =>
      expect(@queues.facebook.queue).to.have.been.calledWith(id, 'http://example.org', new Date(2 * 3600 * 1000))
      done()

  it 'should queue another fetch in two hours on database error', (done) ->
    UrlPopularityGet.create.returns(Promise.reject('db error'))
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch 'facebook', id, 'http://example.org', =>
      expect(@queues.facebook.queue).to.have.been.calledWith(id, 'http://example.org', new Date(2 * 3600 * 1000))
      done()
