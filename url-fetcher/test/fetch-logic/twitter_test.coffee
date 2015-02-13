f = require('../../lib/fetch-logic/twitter')

describe 'fetch-logic/twitter', ->
  beforeEach ->
    @oldRequest = f.request
    f.request =
      get: sinon.stub().callsArgWith(1, null, 200, '{ "count": 7 }')

  afterEach ->
    f.request = @oldRequest

  it 'should GET a special URL', (done) ->
    url = 'http://example.org?foo=bar'
    f url, ->
      expect(f.request.get).to.have.been.calledWith("https://cdn.api.twitter.com/1/urls/count.json?url=#{encodeURIComponent(url)}")
      done()

  it 'should error on GET error', (done) ->
    f.request.get.callsArgWith(1, 'err')
    f 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should give "n" as number of shares', (done) ->
    f.request.get.callsArgWith(1, null, 200, '{ "count": 2 }')
    f 'http://example.org', (err, data) ->
      expect(data.n).to.equal(2)
      done()
