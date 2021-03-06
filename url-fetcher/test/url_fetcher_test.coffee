UrlFetcher = require('../lib/url_fetcher')
Promise = require('bluebird')
models = require('../../data-store').models

Url = models.Url
UrlGet = models.UrlGet

DayInMs = 86400 * 1000

describe 'UrlFetcher', ->
  beforeEach ->
    @response =
      statusCode: 200
      headers: { connection: 'keep-alive' }
      body: '<html><body>hello</body></html>'
    @insertResponse = {}
    @insertResponse[k] = v for k, v of @response
    @insertResponse.responseHeaders = @insertResponse.headers
    delete @insertResponse.headers

    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @sandbox.clock.tick(32 * DayInMs)

    @sandbox.stub(UrlFetcher.request, 'get').callsArgWith(1, null, @response)
    @sandbox.stub(UrlGet, 'create')

    @fetcher = new UrlFetcher()

  afterEach ->
    @sandbox.restore()

  it 'should GET the page', (done) ->
    UrlGet.create.returns(Promise.reject(null))
    @fetcher.fetch '560f5f77-5b44-46cf-a3a8-1722917184de', 'http://example.org', ->
      expect(UrlFetcher.request.get).to.have.been.called
      expect(UrlFetcher.request.get.args[0][0]).to.have.property('url', 'http://example.org')
      done()

  it 'should identify as EmergentBot', (done) ->
    UrlGet.create.returns(Promise.reject(null))
    @fetcher.fetch '560f5f77-5b44-46cf-a3a8-1722917184de', 'http://example.org', ->
      expect(UrlFetcher.request.get.args[0][0].headers).to.have.property('User-Agent', 'EmergentBot (+http://www.emergent.info)')
      done()

  it 'should error when the GET errors', (done) ->
    UrlFetcher.request.get.callsArgWith(1, 'err')
    @fetcher.fetch '560f5f77-5b44-46cf-a3a8-1722917184de', 'http://example.org', (err) ->
      expect(err).to.eq('err')
      done()

  it 'should create the UrlGet', (done) ->
    id = 'ebe55890-aea7-4130-84f6-1ad31251fa0f'
    UrlGet.create.returns(Promise.resolve(null))
    @fetcher.fetch id, 'http://example.org', =>
      expect(UrlGet.create).to.have.been.called
      data = UrlGet.create.lastCall.args[0]
      expect(data.urlId).to.eq(id)
      expect(data.statusCode).to.eq(@response.statusCode)
      expect(data.responseHeaders).to.eq(JSON.stringify(@response.headers))
      expect(data.body).to.eq(@response.body)
      done()

  it 'should error when the UrlGet creation errors', (done) ->
    UrlGet.create.returns(Promise.reject('err'))
    @fetcher.fetch '560f5f77-5b44-46cf-a3a8-1722917184de', 'http://example.org', (err) ->
      expect(err).to.eq('err')
      done()

  it 'should call the callback with the url_get record', (done) ->
    UrlGet.create.returns(Promise.resolve(@insertResponse))
    @fetcher.fetch '560f5f77-5b44-46cf-a3a8-1722917184de', 'http://example.org', (err, data) =>
      expect(data.id).to.eq(@insertResponse.id)
      expect(data.statusCode).to.eq(@insertResponse.statusCode)
      expect(data.responseHeaders).to.deep.eq(@insertResponse.responseHeaders)
      expect(data.body.toString('base64')).to.eq(@response.body)
      done()
