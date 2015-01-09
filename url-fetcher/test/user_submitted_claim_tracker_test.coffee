Promise = require('bluebird')

models = require('../../data-store').models
Url = models.Url
UserSubmittedClaim = models.UserSubmittedClaim
UserSubmittedClaimTracker = require('../lib/user_submitted_claim_tracker')

describe 'UserSubmittedClaimTracker', ->
  beforeEach ->
    @uscId = '61d31471-ae64-4328-b5e8-096f27f30468'
    @urlId = 'ecda2eaf-6475-4929-be8b-5dc11f3898f7'
    @url = 'http://example.org/foo'

    @sandbox = sinon.sandbox.create()
    @sandbox.stub(Url, 'upsert').returns(Promise.resolve([ { id: @urlId, url: @url }, true ]))
    @sandbox.stub(UserSubmittedClaim, 'find').returns(Promise.resolve({ id: @uscId, url: @url }))
    @sandbox.stub(UserSubmittedClaim, 'partialUpdate').returns(Promise.resolve(0))
    @jobQueue = { queue: @sandbox.stub().callsArg(1) }

    @subject = new UserSubmittedClaimTracker
      jobQueue: @jobQueue

  afterEach ->
    @sandbox.restore()

  it 'should filter by spam', (done) ->
    @subject.trackRandomUntrackedUrl (err, res) ->
      expect(UserSubmittedClaim.find).to.have.been.called
      expect(UserSubmittedClaim.find.args[0][0]).to.have.property('spam', false)
      done()

  it 'should filter by urlId IS NULL', (done) ->
    @subject.trackRandomUntrackedUrl (err, res) ->
      expect(UserSubmittedClaim.find).to.have.been.called
      expect(UserSubmittedClaim.find.args[0][0]).to.have.property('urlId', null)
      done()

  it 'should do nothing when there is no UserSubmittedClaim', (done) ->
    UserSubmittedClaim.find.returns(Promise.resolve(null))
    @subject.trackRandomUntrackedUrl (err, res) ->
      expect(Url.upsert).not.to.have.been.called
      expect(UserSubmittedClaim.partialUpdate).not.to.have.been.called
      done()

  it 'should upsert a Url', (done) ->
    @subject.trackRandomUntrackedUrl (err, res) =>
      expect(Url.upsert).to.have.been.calledWith({ url: @url }, null)
      done()

  it 'should queue the Url for tracking', (done) ->
    @subject.trackRandomUntrackedUrl (err, res) =>
      expect(@jobQueue.queue).to.have.been.calledWith(id: @urlId, url: @url)
      done()

  it 'should set urlId on the UserSubmittedClaim', (done) ->
    @subject.trackRandomUntrackedUrl (err, res) =>
      expect(UserSubmittedClaim.partialUpdate).to.have.been.calledWith({ id: @uscId }, { urlId: @urlId }, null)
      done()

  describe 'when the Url was created after we created the UserSubmittedClaim but before we tried tracking it', ->
    beforeEach ->
      Url.upsert.returns(Promise.resolve([ { id: @urlId, url: @url }, false ]))

    it 'should not queue the Url', (done) ->
      @subject.trackRandomUntrackedUrl (err, res) =>
        expect(@jobQueue.queue).not.to.have.been.called
        done()

    it 'should set urlId on the UserSubmittedClaim', (done) ->
      @subject.trackRandomUntrackedUrl (err, res) =>
        expect(UserSubmittedClaim.partialUpdate).to.have.been.calledWith({ id: @uscId }, { urlId: @urlId }, null)
        done()

  it 'should return null', (done) ->
    @subject.trackRandomUntrackedUrl (err, res) =>
      expect(err).to.be.null
      expect(res).to.be.null
      done()
