UrlFetcher = require('../lib/url_fetcher')
ObjectID = require('mongodb').ObjectID

describe 'url_fetcher', ->
  beforeEach ->
    @response =
      statusCode: 200
      headers: { connection: 'keep-alive' }
      body: '<html><body>hello</body></html>'

    @sandbox = sinon.sandbox.create(useFakeTimers: true)
    @sandbox.stub(UrlFetcher.request, 'get').callsArgWith(1, null, @response)

    @urlGets =
      insert: sinon.stub().callsArgWith(1, null, @response) # @response is close enough
      createIndex: sinon.stub()

    @fetcher = new UrlFetcher
      urlGets: @urlGets

  afterEach -> @sandbox.restore()

  it 'should create an index on urlGets, ignoring errors', ->
    @urlGets.createIndex.callsArgWith(1, 'err')
    fetcher2 = new UrlFetcher
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
      expect(@urlGets.insert).to.have.been.calledWith
        urlId: id
        createdAt: new Date()
        headers: @response.headers
        statusCode: @response.statusCode
        body: @response.body
      done()

  it 'should error when the urlFetches insertion errors', (done) ->
    @urlGets.insert.callsArgWith(1, 'err')
    @fetcher.fetch new ObjectID(), 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should call the callback with the status, headers and body', (done) ->
    @fetcher.fetch new ObjectID(), 'http://example.org', (err, data) =>
      expect(data).to.deep.eq(@response)
      done()
