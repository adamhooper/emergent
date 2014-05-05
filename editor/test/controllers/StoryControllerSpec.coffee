describe 'StoryController', ->
  model = () -> sails.models.story

  afterEach ->
    model().destroy()

  mockStory = (options) ->
    _.extend(
      slug: 'slug-a',
      headline: 'headline'
      description: 'foo'
      createdBy: 'foo@example.org'
      updatedBy: 'bar@example.org'
    , options)

  describe '#index', ->
    req = ->
      supertest(app)
        .get('/stories')
        .set('Accept', 'application/json')

    it 'should return JSON with a JSONish request', (done) ->
      req()
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect([])
        .expect(200)
        .end(done)

    describe 'when there are Stories', ->
      beforeEach ->
        Q.all([
          model().create(mockStory(slug: 'slug-a'))
          model().create(mockStory(slug: 'slug-b'))
        ])

      it 'should return the stories', (done) ->
        req()
          .expect (res) ->
            res.body.map((x) -> x.slug).should.deep.equal([ 'slug-a', 'slug-b' ])
            undefined
          .end(done)

  describe '#create', ->
    req = (object) ->
      object ?= {}
      object.slug ?= 'slug-a'
      object.headline ?= 'headline'

      supertest(app)
        .post('/stories')
        .set('Accept', 'application/json')
        .send(object)

    reqAndFetchFromDb = (object) ->
      Q.npost(req(object), 'end')
        .then -> model().findOne(slug: 'slug-a')

    it 'should return a JSON response with the given object', (done) ->
      req()
        .expect(200)
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect (res) ->
          res.body.slug.should.equal('slug-a')
          undefined
        .end(done)

    it 'should store the story', ->
      reqAndFetchFromDb()
        .should.eventually.contain(slug: 'slug-a')

    it 'should add the user to the story as createdBy and updatedBy', ->
      reqAndFetchFromDb()
        .should.eventually.contain(createdBy: 'user@example.org', updatedBy: 'user@example.org')

    it 'should not let the user manually set createdBy', ->
      Q.npost(req(slug: 'slug-a', createdBy: 'user2@example.org'), 'end')
        .should.eventually.contain(status: 400)

    it 'should return a JSON error when there is no slug', (done) ->
      req(slug: '')
        .expect(400)
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect (res) ->
          Object.keys(res.body.invalidAttributes).should.deep.equal(['slug'])
          undefined
        .end(done)

    it 'should return an error when the slug is not permalink-ish', ->
      Q.npost(req(slug: 'a/b'), 'end')
        .should.eventually.contain(status: 400)

    it 'should return a JSON error when adding two', (done) ->
      req(slug: 'slug-a').end ->
        req(slug: 'slug-a')
          .expect(400)
          .expect('Content-Type', 'application/json; charset=utf-8')
          .end(done)

  describe '#destroy', ->
    req = (slug) ->
      supertest(app)
        .delete("/stories/#{slug}")
        .set('Accept', 'application/json')

    it 'should return OK when the object does not exist', ->
      Q.npost(req('foo'), 'end')
        .should.eventually.contain(status: 200)

    it 'should return ok when the object exists', ->
      model().create(mockStory(slug: 'foo'))
        .then -> Q.npost(req('foo'), 'end')
        .should.eventually.contain(status: 200)

    it 'should delete the story when it exists', ->
      model().create(mockStory(slug: 'foo'))
        .then -> Q.npost(req('foo'), 'end')
        .then -> model().findOne(slug: 'foo')
        .should.eventually.equal(undefined)

    it 'should do nothing when the slug is missing from the request', ->
      model().create(mockStory(slug: 'foo'))
        .then -> Q.npost(req(''), 'end')
        .then -> model().findOne(slug: 'foo')
        .should.eventually.contain(slug: 'foo')

  describe '#update', ->
    req = (object, slug) ->
      slug ?= object.slug
      toSend = {}
      for k, v of object
        toSend[k] = v
      delete toSend.slug
      supertest(app)
        .put("/stories/#{slug}")
        .set('Accept', 'application/json')
        .send(toSend)

    beforeEach ->
      model().create(mockStory(slug: 'slug-a', description: 'foo'))

    it 'should return 404 when the object does not exist', ->
      Q.npost(req(slug: 'slug-b'), 'end')
        .should.eventually.contain(status: 404)

    it 'should return 400 when the slug is wrong', (done) ->
      supertest(app)
        .put('/stories/slug-a')
        .set('Accept', 'application/json')
        .send(slug: 'slug-b')
        .expect(400, done)

    it 'should return 200 OK', ->
      Q.npost(req(slug: 'slug-a', description: 'bar'), 'end')
        .should.eventually.contain(status: 200)

    it 'should not update other objects', ->
      Q.npost(req(slug: 'slug-b', description: 'bar'), 'end')
        .then -> model().findOne(slug: 'slug-a')
        .should.eventually.contain(description: 'foo')

    it 'should update the object in question', ->
      Q.npost(req(slug: 'slug-a', description: 'bar'), 'end')
        .then -> model().findOne(slug: 'slug-a')
        .should.eventually.contain(description: 'bar')

    it 'should return the updated object', ->
      Q.npost(req(slug: 'slug-a', description: 'bar'), 'end')
        .then((res) -> res.body)
        .should.eventually.contain(description: 'bar')

    it 'should set updatedBy', ->
      Q.npost(req(slug: 'slug-a', description: 'foo'), 'end')
        .then -> model().findOne(slug: 'slug-a')
        .should.eventually.contain(updatedBy: 'user@example.org')

    it 'should not let the user set updatedBy', ->
      Q.npost(req(slug: 'slug-a', updatedBy: 'user2@example.org'), 'end')
        .should.eventually.contain(status: 400)

    it 'should not let the user set createdBy', ->
      Q.npost(req(slug: 'slug-a', createdBy: 'user2@exampel.org'), 'end')
        .should.eventually.contain(status: 400)
