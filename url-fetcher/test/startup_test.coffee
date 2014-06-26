Startup = require('../lib/startup')

describe 'startup', ->
  beforeEach -> @clock = sinon.useFakeTimers()
  afterEach -> @clock.restore()

  beforeEach ->
    @articles =
      find: sinon.stub().returns(toArray: (cb) -> cb(null, []))
    @urls =
      update: sinon.stub()
      find: sinon.stub().returns({ toArray: (cb) -> cb(null, []) })
      createIndex: sinon.stub().callsArgWith(2, null, null)
    @queue =
      queue: sinon.spy()
    @startup = new Startup(articles: @articles, urls: @urls, queue: @queue)

  it 'should index urls', (done) ->
    @startup.run (err) =>
      expect(@urls.createIndex).to.have.been.calledWith('url', unique: true)
      done()

  it 'should search for articles', (done) ->
    @startup.run (err) =>
      expect(@articles.find).to.have.been.calledWith({}, url: 1)
      done()

  it 'should run a callback', (done) ->
    @startup.run (err) ->
      expect(err).to.be.falsy
      done()

  it 'should error when articles cannot be searched', (done) ->
    @articles.find.returns(toArray: (cb) -> cb('err'))
    @startup.run (err) ->
      expect(err).to.equal('err')
      done()

  describe 'with some articles', ->
    beforeEach ->
      @foundArticles = []
      @articles.find.returns(toArray: (cb) => cb(null, @foundArticles))
      @urls.update.callsArgWith(3, null)

    it 'should upsert the urls', (done) ->
      @foundArticles.push(url: 'http://example.org')
      @foundArticles.push(url: 'http://example2.org')
      @startup.run =>
        expect(@urls.update).to.have.been.calledWith({ url: 'http://example.org' }, { $set: { url: 'http://example.org' } }, upsert: true)
        expect(@urls.update).to.have.been.calledWith({ url: 'http://example2.org' }, { $set: { url: 'http://example2.org' } }, upsert: true)
        done()

    it 'should error if upserting a url fails', (done) ->
      @foundArticles.push(url: 'http://example.org')
      @urls.update.callsArgWith(3, 'err')
      @startup.run (err) ->
        expect(err).to.equal('err')
        done()

    it 'should move on to finding urls', (done) ->
      @foundArticles.push(url: 'http://example.org')
      @startup.run =>
        expect(@urls.find).to.have.been.called
        done()

  describe 'with some urls', ->
    beforeEach ->
      @foundUrls = []
      @articles.find.returns(toArray: (cb) -> cb(null, []))
      @urls.find.returns(toArray: (cb) => cb(null, @foundUrls))

    it 'should error if url-finding fails', (done) ->
      @urls.find.returns(toArray: (cb) => cb('err'))
      @startup.run (err) ->
        expect(err).to.equal('err')
        done()

    describe 'with an unfetched url', ->
      beforeEach ->
        @foundUrls.push(_id: 'abcdef', url: 'http://example.org')

      it 'should schedule immediate facebook, google and twitter jobs', (done) ->
        @startup.run =>
          expect(@queue.queue).to.have.been.calledWith('google', 'abcdef')
          expect(@queue.queue).to.have.been.calledWith('facebook', 'abcdef')
          expect(@queue.queue).to.have.been.calledWith('twitter', 'abcdef')
          done()

    describe 'with a partially fetched url', ->
      beforeEach ->
        @foundUrls.push(_id: 'abcdef', url: 'http://example.org', shares: { facebook: { n: 3, updatedAt: new Date(123) }})
        @clock.tick(3600 * 1000) # 1hr

      it 'should schedule an immediate job for the missing parts', (done) ->
        @startup.run =>
          expect(@queue.queue).to.have.been.calledWith('google', 'abcdef', 'http://example.org', new Date(3600 * 1000))
          expect(@queue.queue).to.have.been.calledWith('twitter', 'abcdef', 'http://example.org', new Date(3600 * 1000))
          done()

      it 'should schedule a delayed job for the fresh parts at the proper time', (done) ->
        @startup.run =>
          expect(@queue.queue).to.have.been.calledWith('facebook', 'abcdef', 'http://example.org', new Date(123 + 2 * 3600 * 1000)) # I can't be bothered to figure out why the -1ms
          done()

    describe 'with a long-ago fetched url', ->
      beforeEach ->
        @foundUrls.push(_id: 'abcdef', url: 'http://example.org', shares: { facebook: { n: 3, updatedAt: new Date() }})
        @clock.tick(2 * 3600 * 1000 + 1) # 2hrs + 1ms

      it 'should schedule an immediate job for the missing parts', (done) ->
        @startup.run =>
          expect(@queue.queue).to.have.been.calledWith('facebook', 'abcdef')
          done()
