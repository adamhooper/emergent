UrlPopularityFetcher = require('../lib/url_popularity_fetcher')
Promise = require('bluebird')
models = require('../../data-store').models

Url = models.Url
UrlPopularityGet = models.UrlPopularityGet

describe 'UrlPopularityFetcher', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @sandbox.stub(UrlPopularityGet, 'create').returns(Promise.resolve(null))
    @sandbox.stub(Url, 'bulkUpdate').returns(Promise.resolve(null))

    @queue =
      queue: sinon.spy()

    @fetchLogic = sinon.stub().callsArgWith(1, null, { n: 10 })

    @timeChooser =
      chooseTime: sinon.stub().returns(1000)

    @fetcher = new UrlPopularityFetcher
      service: 'facebook'
      fetchLogic: @fetchLogic
      taskTimeChooser: @timeChooser

    @fetch = (urlId, url, nPreviousFetches, callback) =>
      @fetcher.fetch(@queue, {
        urlId: urlId
        url: url
        nPreviousFetches: nPreviousFetches
        at: new Date(0)
      }, callback)

  afterEach ->
    @sandbox.restore()

  it 'should call the appropriate fetch logic', (done) ->
    @fetch '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', 0, =>
      expect(@fetchLogic).to.have.been.calledWith('http://example.org')
      done()

  it 'should error when the fetch logic errors', (done) ->
    @fetchLogic.callsArgWith(1, 'err')
    @fetch '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', 0, (err) =>
      expect(err.message).to.equal('err')
      done()

  it 'should create a UrlPopularityGet', (done) ->
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetch id, 'http://example.org', 0, =>
      expect(UrlPopularityGet.create).to.have.been.calledWith(urlId: id, shares: 10, service: 'facebook')
      done()

  it 'should call Url.bulkUpdate to set the share count', (done) ->
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @fetch id, 'http://example.org', 0, =>
      expect(Url.bulkUpdate).to.have.been.calledWith({ cachedNSharesFacebook: 10 }, { id: id }, null)
      done()

  it 'should error when the UrlPopularityGet creation fails', (done) ->
    UrlPopularityGet.create.returns(Promise.reject('err'))
    @fetch '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', 0, (err) ->
      expect(err).to.equal('err')
      done()

  it 'should error when Url update fails', (done) ->
    Url.bulkUpdate.returns(Promise.reject('err'))
    @fetch '04808471-2828-467c-a6f3-c36754b2406d', 'http://example.org', 0, (err) ->
      expect(err).to.equal('err')
      done()

  it 'should queue another fetch on success', (done) ->
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @sandbox.clock.tick(1000)
    @timeChooser.chooseTime.returns(new Date(3000))
    @fetch id, 'http://example.org', 5, =>
      expect(@timeChooser.chooseTime).to.have.been.calledWith(6, new Date(1000))
      expect(@queue.queue).to.have.been.calledWith
        urlId: id
        url: 'http://example.org'
        nPreviousFetches: 6
        at: new Date(3000)
      done()

  it 'should queue another fetch fetching error', (done) ->
    @fetchLogic.callsArgWith(1, 'err')
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @timeChooser.chooseTime.returns(new Date(3000))
    @fetch id, 'http://example.org', 5, =>
      expect(@queue.queue).to.have.been.calledWith
        urlId: id
        url: 'http://example.org'
        nPreviousFetches: 6
        at: new Date(3000)
      done()

  it 'should queue another fetch on database error', (done) ->
    UrlPopularityGet.create.returns(Promise.reject('db error'))
    id = '04808471-2828-467c-a6f3-c36754b2406d'
    @timeChooser.chooseTime.returns(new Date(3000))
    @fetch id, 'http://example.org', 5, =>
      expect(@queue.queue).to.have.been.calledWith
        urlId: id
        url: 'http://example.org'
        nPreviousFetches: 6
        at: new Date(3000)
      done()

  it 'should not queue another fetch if the time chooser returns null', (done) ->
    @timeChooser.chooseTime.returns(null)
    @fetch '0704537d-a49a-476f-8a3a-bbc06566e302', 'http://example.org', 5, =>
      expect(@queue.queue).not.to.have.been.called
      done()
