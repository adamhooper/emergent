UrlCreator = require('../lib/url_creator')
ObjectID = require('mongodb').ObjectID

describe 'url_creator', ->
  beforeEach ->
    @urls =
      update: sinon.stub().callsArgWith(3, null, 1, updatedExisting: true)
    @queue =
      queue: sinon.spy()

    @creator = new UrlCreator
      urls: @urls
      queue: @queue
      services: [ 'facebook', 'twitter', 'google' ]

  it 'should try to upsert the URL', (done) ->
    @creator.create 'http://example.org', (err) =>
      expect(@urls.update).to.have.been.calledWith({ url: 'http://example.org' }, { $set: { url: 'http://example.org' } }, { w: 1, upsert: true })
      done()

  it 'should try to update and throw error on error', (done) ->
    @urls.update.callsArgWith(3, 'err')
    @creator.create 'http://example.org', (err) =>
      expect(@queue.queue).not.to.have.been.called
      expect(err).to.equal(err)
      done()

  it 'should queue the URL fetch when the URL is new', (done) ->
    @urls.update.callsArgWith(3, null, 1, { updatedExisting: false, upserted: [ { _id: new ObjectID('537f42523757cc8ce9ed462e') } ] })
    @creator.create 'http://example.org', =>
      expect(@queue.queue).to.have.been.calledWith('facebook', new ObjectID('537f42523757cc8ce9ed462e'))
      expect(@queue.queue).to.have.been.calledWith('twitter', new ObjectID('537f42523757cc8ce9ed462e'))
      expect(@queue.queue).to.have.been.calledWith('google', new ObjectID('537f42523757cc8ce9ed462e'))
      done()

  it 'should do nothing when the URL is already present', (done) ->
    @urls.update.callsArgWith(3, null, 1, { updatedExisting: true })
    @creator.create 'http://example.org', =>
      expect(@queue.queue).not.to.have.been.called
      done()
