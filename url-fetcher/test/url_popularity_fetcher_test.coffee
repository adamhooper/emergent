UrlPopularityFetcher = require('../lib/url_popularity_fetcher')
Promise = require('bluebird')
models = require('../../data-store').models

UrlPopularityGet = models.UrlPopularityGet

describe 'url_popularity_fetcher', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @sandbox.stub(UrlPopularityGet, 'create').returns(Promise.resolve(null))

    @queue =
      queue: sinon.spy()

    @fetchLogic = sinon.stub().callsArgWith(1, null, { n: 10, rawData: { foo: 'bar' }})

    @fetcher = new UrlPopularityFetcher
      service: 'facebook'
      fetchLogic: @fetchLogic

  afterEach ->
    @sandbox.restore()

  it 'should call the appropriate fetch logic', (done) ->
    @fetcher.fetch @queue, '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', =>
      expect(@fetchLogic).to.have.been.calledWith('http://example.org')
      done()

  it 'should error when the fetch logic errors', (done) ->
    @fetchLogic.callsArgWith(1, 'err')
    @fetcher.fetch @queue, '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', (err) =>
      expect(err.message).to.equal('err')
      done()

  it 'should create a UrlPopularityGet', (done) ->
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch @queue, id, 'http://example.org', =>
      expect(UrlPopularityGet.create).to.have.been.calledWith(urlId: id, shares: 10, service: 'facebook', rawData: { foo: 'bar' })
      done()

  it 'should error when the urlFetches insertion errors', (done) ->
    UrlPopularityGet.create.returns(Promise.reject('err'))
    @fetcher.fetch @queue, '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should queue another fetch in two hours on success', (done) ->
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch @queue, id, 'http://example.org', =>
      expect(@queue.queue).to.have.been.calledWith(id, 'http://example.org', new Date(1 * 3600 * 1000))
      done()

  it 'should queue another fetch in two hours on fetching error', (done) ->
    @fetchLogic.callsArgWith(1, 'err')
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch @queue, id, 'http://example.org', =>
      expect(@queue.queue).to.have.been.calledWith(id, 'http://example.org', new Date(1 * 3600 * 1000))
      done()

  it 'should queue another fetch in two hours on database error', (done) ->
    UrlPopularityGet.create.returns(Promise.reject('db error'))
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetcher.fetch @queue, id, 'http://example.org', =>
      expect(@queue.queue).to.have.been.calledWith(id, 'http://example.org', new Date(1 * 3600 * 1000))
      done()
