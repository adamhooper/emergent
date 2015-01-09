describe 'UserSubmittedClaimController', ->
  models = require('../../../data-store').models
  Url = models.Url
  UserSubmittedClaim = models.UserSubmittedClaim

  createUserSubmittedClaim = (attributes) ->
    attributes = _.extend({
      claim: 'claim'
      url: 'http://example.com/claim'
      createdAt: new Date(1234)
      spam: false
      archived: false
      urlId: null
      requestIp: '127.0.0.1'
    }, attributes)
    UserSubmittedClaim.create(attributes, null)

  describe '#index', ->
    req = ->
      ret = supertest(app).get('/user-submitted-claims').set('Accept', 'application/json')
      Promise.promisify(ret.end, ret)()

    it 'should return the useful attributes', ->
      attributes =
        requestIp: '192.168.1.1'
        createdAt: new Date(10000)
        claim: 'something happened'
        url: 'http://example.org/something'
      createUserSubmittedClaim(attributes)
        .then(-> req())
        .tap (res) ->
          usc = res.body[0]
          expect(usc.requestIp).to.eq('192.168.1.1')
          expect(usc.createdAt).to.eq(new Date(10000).toISOString())
          expect(usc.claim).to.eq('something happened')
          expect(usc.url).to.eq('http://example.org/something')

    it 'should sort by createdAt', ->
      usc1 = null
      usc2 = null
      usc3 = null
      Promise.all([
        createUserSubmittedClaim(createdAt: new Date(2000))
        createUserSubmittedClaim(createdAt: new Date(3000))
        createUserSubmittedClaim(createdAt: new Date(1000))
      ])
        .tap(([ x1, x2, x3 ]) -> usc1 = x1; usc2 = x2; usc3 = x3)
        .then(-> req())
        .tap (res) ->
          expect(res.statusCode).to.eq(200)
          expect(res.body).to.have.length(3)
          expect(_.pluck(res.body, 'id')).to.deep.eq([ usc3.id, usc1.id, usc2.id ])

    it 'should filter out spam', ->
      createUserSubmittedClaim(spam: true)
        .then(-> req())
        .tap((res) -> expect(res.body).to.have.length(0))

    it 'should filter out archived', ->
      createUserSubmittedClaim(archived: true)
        .then(-> req())
        .tap((res) -> expect(res.body).to.have.length(0))

  describe '#update', ->
    req = (id, json) ->
      ret = supertest(app)
        .patch("/user-submitted-claims/#{id}")
        .set('Accept', 'application/json')
        .send(json)
      Promise.promisify(ret.end, ret)()

    # Does this:
    #
    # 1. creates a submitted claim with originalAttributes
    # 2. calls #update() with newAttributes
    # 3. fetches the UserSubmittedClaim from the database
    update = (originalAttributes, newAttributes) ->
      createUserSubmittedClaim(originalAttributes)
        .tap((usc) -> req(usc.id, newAttributes))
        .then((usc) -> models.UserSubmittedClaim.find(usc.id))

    it 'should return 404 when claim is not found', ->
      createUserSubmittedClaim() # some other claim that shouldn't be found
        .then(-> req('617ee90a-320d-449c-9f05-9dfb690180e9', spam: true))
        .tap (res) ->
          expect(res.statusCode).to.eq(404)

    it 'should return 400 when neither spam nor archived is set', ->
      req('617ee90a-320d-449c-9f05-9dfb690180e9', foo: 'bar')
        .tap (res) ->
          expect(res.statusCode).to.eq(400)

    it 'should return 404 when passed claim ID is not a UUID', ->
      createUserSubmittedClaim() # some other claim that shouldn't be found
        .then(-> req('617ee90a-320d-449c-9f05-9dfb690180e', spam: true))
        .tap (res) ->
          expect(res.statusCode).to.eq(404)

    it 'should return 204', ->
      createUserSubmittedClaim()
        .then((usc) -> req(usc.id, spam: true))
        .tap (res) ->
          expect(res.statusCode).to.eq(204)

    it 'should set spam=true', ->
      update({ spam: false }, { spam: true })
        .tap((usc) -> expect(usc.spam).to.eq(true))

    it 'should set archived=true', ->
      update({ archived: false }, { archived: true })
        .tap((usc) -> expect(usc.archived).to.eq(true))

    it 'should set spam=false', ->
      update({ spam: true }, { spam: false })
        .tap((usc) -> expect(usc.spam).to.eq(false))

    it 'should set archived=false', ->
      update({ archived: true }, { archived: false })
        .tap((usc) -> expect(usc.archived).to.eq(false))
