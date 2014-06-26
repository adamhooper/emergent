UrlPopularityFetcher = require('../lib/url_popularity_fetcher')
ObjectID = require('mongodb').ObjectID

describe 'url_popularity_fetcher', ->
  beforeEach -> @clock = sinon.useFakeTimers()
  afterEach -> @clock.restore()

  beforeEach ->
    @urls =
      update: sinon.stub().callsArgWith(2, null, {})
    @urlFetches =
      insert: sinon.stub().callsArgWith(1, null, {})
      createIndex: sinon.stub()
    @queue =
      queue: sinon.spy()
    @fetchLogic =
      facebook: sinon.stub().callsArgWith(1, null, { n: 10, rawData: { foo: 'bar' }})

    @fetcher = new UrlPopularityFetcher
      urls: @urls
      urlFetches: @urlFetches
      queue: @queue
      fetchLogic: @fetchLogic

  it 'should create an index on urlFetches, ignoring errors', ->
    @urlFetches.createIndex.callsArgWith(1, 'err')
    fetcher2 = new UrlPopularityFetcher
      urls: @urls
      urlFetches: @urlFetches
      queue: @queue
      fetchLogic: @fetchLogic
    expect(@urlFetches.createIndex).to.have.been.calledWith('urlId')

  it 'should call the appropriate fetch logic', (done) ->
    @fetcher.fetch 'facebook', new ObjectID().toString(), 'http://example.org', =>
      expect(@fetchLogic.facebook).to.have.been.calledWith('http://example.org')
      done()

  it 'should error when the fetch logic errors', (done) ->
    @fetchLogic.facebook.callsArgWith(1, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), 'http://example.org', (err) =>
      expect(err).to.equal('err')
      done()

  it 'should insert into the urlFetches collection', (done) ->
    @fetchLogic.facebook.callsArgWith(1, null, { n: 10, rawData: { foo: 'bar' } })
    id = new ObjectID()
    @fetcher.fetch 'facebook', id, 'http://example.org', =>
      expect(@urlFetches.insert).to.have.been.calledWith({ urlId: id, n: 10, service: 'facebook', createdAt: new Date(), rawData: { foo: 'bar' }})
      done()

  it 'should error when the urlFetches insertion errors', (done) ->
    @urlFetches.insert.callsArgWith(1, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should update the urls collection', (done) ->
    @fetchLogic.facebook.callsArgWith(1, null, { n: 10, rawData: { foo: 'bar' } })
    id = new ObjectID()
    @fetcher.fetch 'facebook', id, 'http://example.org', =>
      expect(@urls.update).to.have.been.calledWith({ _id: id }, { '$set': { 'shares.facebook.n': 10, 'shares.facebook.updatedAt': new Date() }})
      done()

  it 'should error when the urls update errors', (done) ->
    @urls.update.callsArgWith(2, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should queue another fetch in two hours', (done) ->
    id = new ObjectID()
    @fetcher.fetch 'facebook', id, 'http://example.org', =>
      expect(@queue.queue).to.have.been.calledWith('facebook', id, 'http://example.org', new Date(2 * 3600 * 1000))
      done()
