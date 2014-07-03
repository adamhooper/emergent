UrlFetcher = require('../lib/url_fetcher')
zlib = require('zlib')
ObjectID = require('mongodb').ObjectID

describe 'url_fetcher', ->
  beforeEach (done) ->
    @response =
      statusCode: 200
      headers: { connection: 'keep-alive' }
      body: '<html><body>hello</body></html>'
    @insertResponse = {}
    @insertResponse[k] = v for k, v of @response

    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @sandbox.stub(UrlFetcher.request, 'get').callsArgWith(1, null, @response)

    @urls =
      update: sinon.stub().callsArgWith(2, null, {})
    @urlGets =
      insert: sinon.stub().callsArgWith(1, null, @insertResponse)
      createIndex: sinon.stub()

    @fetcher = new UrlFetcher
      urls: @urls
      urlGets: @urlGets

    # Actually, we'll be inserting a compressed version of the body
    zlib.gzip @response.body, (err, compressedBody) =>
      @compressedBody = compressedBody
      @insertResponse.body = compressedBody
      done(err)

  afterEach -> @sandbox.restore()

  it 'should create an index on urlGets, ignoring errors', ->
    @urlGets.createIndex.callsArgWith(1, 'err')
    fetcher2 = new UrlFetcher
      urls: @urls
      urlGets: @urlGets
    expect(@urlGets.createIndex).to.have.been.calledWith('urlId')

  it 'should GET the page', (done) ->
    @fetcher.fetch new ObjectID(), 'http://example.org', ->
      expect(UrlFetcher.request.get).to.have.been.calledWith('http://example.org')
      done()

  it 'should error when the GET errors', (done) ->
    UrlFetcher.request.get.callsArgWith(1, 'err')
    @fetcher.fetch new ObjectID(), 'http://example.org', (err) ->
      expect(err).to.eq('err')
      done()

  it 'should insert the request into the urlGets collection', (done) ->
    id = new ObjectID()
    @fetcher.fetch id, 'http://example.org', =>
      expect(@urlGets.insert).to.have.been.called
      data = @urlGets.insert.lastCall.args[0]
      expect(data.urlId).to.eq(id)
      expect(data.createdAt).to.deep.eq(new Date())
      expect(data.statusCode).to.eq(@response.statusCode)
      expect(data.headers).to.deep.eq(@response.headers)
      expect(data.body.toString('base64')).to.eq(@compressedBody.toString('base64'))
      done()

  it 'should set url.urlGet.id when the urlGets insertion succeeds', (done) ->
    id = new ObjectID()
    @insertResponse._id = new ObjectID()
    @fetcher.fetch id, 'http://example.org', =>
      expect(@urls.update).to.have.been.calledWith({ _id: id }, { '$set': { 'urlGet.id': @insertResponse._id, 'urlGet.updatedAt': new Date() }})
      done()

  it 'should error when the urlFetches insertion errors', (done) ->
    @urlGets.insert.callsArgWith(1, 'err')
    @fetcher.fetch new ObjectID(), 'http://example.org', (err) ->
      expect(err).to.eq('err')
      done()

  it 'should error when url.urlGet.id update fails', (done) ->
    @urls.update.callsArgWith(2, 'err')
    @fetcher.fetch new ObjectID(), 'http://example.org', (err) ->
      expect(err).to.eq('err')
      done()

  it 'should not update url.urlGetId if urlFetches insertion errors', (done) ->
    @urlGets.insert.callsArgWith(1, 'err')
    @fetcher.fetch new ObjectID(), 'http://example.org', =>
      expect(@urls.update).not.to.have.been.called
      done()

  it 'should call the callback with the url_get record', (done) ->
    @fetcher.fetch new ObjectID(), 'http://example.org', (err, data) =>
      expect(data._id).to.eq(@insertResponse._id)
      expect(data.statusCode).to.eq(@insertResponse.statusCode)
      expect(data.headers).to.deep.eq(@insertResponse.headers)
      expect(data.body.toString('base64')).to.eq(@insertResponse.body.toString('base64'))
      done()
