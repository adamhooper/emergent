f = require('../../lib/fetch-logic/google')

describe 'fetch-logic/google', ->
  beforeEach ->
    @oldRequest = f.request
    f.request =
      post: sinon.stub().callsArgWith(1, null, 200, {})

  afterEach ->
    f.request = @oldRequest


  it 'should POST to a special URL', (done) ->
    url = 'http://example.org?foo=bar'
    f url, ->
      expect(f.request.post).to.have.been.calledWith
        url: 'https://clients6.google.com/rpc'
        body: [{"method":"pos.plusones.get","id":"p","params":{"nolog":true,"id":url,"source":"widget","userId":"@viewer","groupId":"@self"},"jsonrpc":"2.0","key":"p","apiVersion":"v1"}]
        json: true
      done()

  it 'should error on POST error', (done) ->
    f.request.post.callsArgWith(1, 'err')
    f 'http://example.org', (err) ->
      expect(err).to.equal('err')
      done()

  it 'should give "n" as number of shares', (done) ->
    f.request.post.callsArgWith(1, null, 200, [{"result":{"metadata":{"globalCounts":{"count":23.0}}}}])
    f 'http://example.org', (err, data) ->
      expect(data.n).to.equal(23)
      done()

  it 'should give "rawData" as original data', (done) ->
    rawData = [{"result":{"metadata":{"globalCounts":{"count":23.0}}}}]
    f.request.post.callsArgWith(1, null, 200, rawData)
    f 'http://example.org', (err, data) ->
      expect(data.rawData).to.equal(rawData)
      done()

  it 'should give "n" as 0 when there are no shares', (done) ->
    f.request.post.callsArgWith(1, null, 200, [{}])
    f 'http://example.org', (err, data) ->
      expect(data.n).to.equal(0)
      done()
