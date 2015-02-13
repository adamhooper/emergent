f = require('../../lib/fetch-logic/facebook')

describe 'fetch-logic/facebook', ->
  beforeEach ->
    @oldRequest = f.request
    f.access_token = 'access=token' # needs to be escaped
    f.request =
      get: sinon.stub().callsArgWith(1, null, 200, '{ "shares": 3 }')

  afterEach ->
    f.request = @oldRequest

  it 'should GET a Graph API url with an access_token', (done) ->
    url = 'http://example.org?foo=bar'
    f url, ->
      expect(f.request.get).to.have.been.calledWith("https://graph.facebook.com/v2.0/#{encodeURIComponent(url)}?access_token=access%3Dtoken")
      done()

  it 'should error on GET error', (done) ->
    f.request.get.callsArgWith(1, 'err')
    f 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should give "n" as number of shares', (done) ->
    f.request.get.callsArgWith(1, null, 200, '{ "shares": 4 }')
    f 'http://example.org', (err, data) ->
      expect(data.n).to.equal(4)
      done()

  it 'should give "n" as 0 when there are no shares', (done) ->
    f.request.get.callsArgWith(1, null, 200, '{ "id": "http://example.org" }')
    f 'http://example.org', (err, data) ->
      expect(data.n).to.equal(0)
      done()
