UrlPopularityFetcher = require('../lib/url_popularity_fetcher')
ObjectID = require('mongodb').ObjectID

describe 'url_popularity_fetcher', ->
  beforeEach -> @clock = sinon.useFakeTimers()
  afterEach -> @clock.restore()

  beforeEach ->
    @urls =
      findOne: sinon.stub().callsArgWith(2, null, { url: 'http://example.org' })
      update: sinon.stub().callsArgWith(2, null, {})
    @urlFetches =
      insert: sinon.stub().callsArgWith(1, null, {})
      createIndex: sinon.stub()
    @queue =
      pushWithDelay: sinon.stub().callsArgWith(3, null, {})
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

  it 'should find the URL given the ID', (done) ->
    @urls.findOne.callsArgWith(2, 'err')
    @fetcher.fetch 'facebook', '53763c763cb763ec6b604920', =>
      expect(@urls.findOne).to.have.been.calledWith({ _id: new ObjectID('53763c763cb763ec6b604920') }, { url: 1 })
      done()

  it 'should error if the given ID does not specify a URL', (done) ->
    @urls.findOne.callsArgWith(2, null, null)
    id = new ObjectID()
    @fetcher.fetch 'facebook', id, (err) ->
      expect(err).to.equal("Could not find URL with id #{id}")
      done()

  it 'should error if finding the URL errors', (done) ->
    @urls.findOne.callsArgWith(2, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), (err) ->
      expect(err).to.equal('err')
      done()

  it 'should call the appropriate fetch logic', (done) ->
    @urls.findOne.callsArgWith(2, null, { url: 'http://example.org' })
    @fetcher.fetch 'facebook', new ObjectID().toString(), =>
      expect(@fetchLogic.facebook).to.have.been.calledWith('http://example.org')
      done()

  it 'should error when the fetch logic errors', (done) ->
    @fetchLogic.facebook.callsArgWith(1, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), (err) =>
      expect(err).to.equal('err')
      done()

  it 'should insert into the urlFetches collection', (done) ->
    @fetchLogic.facebook.callsArgWith(1, null, { n: 10, rawData: { foo: 'bar' } })
    id = new ObjectID()
    @fetcher.fetch 'facebook', id.toString(), =>
      expect(@urlFetches.insert).to.have.been.calledWith({ urlId: id, n: 10, service: 'facebook', createdAt: new Date(), rawData: { foo: 'bar' }})
      done()

  it 'should error when the urlFetches insertion errors', (done) ->
    @urlFetches.insert.callsArgWith(1, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), (err) ->
      expect(err).to.equal('err')
      done()

  it 'should update the urls collection', (done) ->
    @fetchLogic.facebook.callsArgWith(1, null, { n: 10, rawData: { foo: 'bar' } })
    id = new ObjectID()
    @fetcher.fetch 'facebook', id.toString(), =>
      expect(@urls.update).to.have.been.calledWith({ _id: id }, { '$set': { 'shares.facebook.n': 10, 'shares.facebook.updatedAt': new Date() }})
      done()

  it 'should error when the urls update errors', (done) ->
    @urls.update.callsArgWith(2, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), (err) ->
      expect(err).to.equal('err')
      done()

  it 'should queue another fetch in two hours', (done) ->
    id = new ObjectID()
    @fetcher.fetch 'facebook', id.toString(), =>
      expect(@queue.pushWithDelay).to.have.been.calledWith('facebook', id, 2 * 3600 * 1000)
      done()

  it 'should error if the queue fetch errors', (done) ->
    @queue.pushWithDelay.callsArgWith(3, 'err')
    @fetcher.fetch 'facebook', new ObjectID().toString(), (err) ->
      expect(err).to.equal('err')
      done()
