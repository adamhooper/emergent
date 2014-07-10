UrlVersionStore = require('../lib/url_version_store')
ObjectID = require('mongodb').ObjectID

describe 'url_version_store', ->
  beforeEach ->
    @urlVersions =
      insert: sinon.stub().callsArgWith(1, null, {})
      createIndex: sinon.stub()

    @subject = new UrlVersionStore
      urlVersions: @urlVersions

  describe 'even when createIndex fails', ->
    beforeEach ->
      @urlVersions.createIndex.withArgs('sha1').callsArgWith(2, 'err')
      @urlVersions.createIndex.callsArgWith(1, 'err')
      new UrlVersionStore
        urlVersions: @urlVersions

    it 'should create a querying index on urlVersions, ignoring errors', ->
      expect(@urlVersions.createIndex).to.have.been.calledWith(urlId: 1, createdAt: -1)

    it 'should create a unique index on sha1, ignoring errors', ->
      expect(@urlVersions.createIndex).to.have.been.calledWith('sha1', unique: true, dropDups: true)

  describe 'when storing an Object', ->
    beforeEach ->
      @example =
        urlId: new ObjectID('53bee976307efe8b6d96bfd1')
        publishedAt: new Date('2014-07-10T12:12:12.000Z')
        source: 'The New York Times'
        headline: 'Man bites dog'
        byline: 'Adam Hooper, Craig Silverman'
        body: 'He came.\n\nHe saw.\n\nHe bit.'

      hash = require('crypto').createHash('sha1')
      hash.update('53bee976307efe8b6d96bfd1\u0000The New York Times\u0000Man bites dog\u0000Adam Hooper, Craig Silverman\u00002014-07-10T12:12:12.000Z\u0000He came.\n\nHe saw.\n\nHe bit.', 'utf-8')
      @sha1 = hash.digest() # a Buffer

      @go = (callback) => @subject.insert(@example, callback)

    for key in [ 'urlId', 'source', 'headline', 'byline', 'body', 'publishedAt' ]
      it "should error if there is no #{key}", (done) ->
        delete @example[key]
        @go (err) ->
          expect(err).to.exist
          done()

    it 'should call urlVersions.insert() with a sha1', (done) ->
      expected = {}
      for k, v of @example
        expected[k] = v
      expected.sha1 = @sha1

      @go (err) =>
        expect(err).to.be.null
        expect(@urlVersions.insert).to.have.been.calledWith(expected)
        done()

    it 'should throw an error if insert fails', (done) ->
      @urlVersions.insert.callsArgWith(1, 'err')
      @go (err) =>
        expect(err).to.eq('err')
        done()
