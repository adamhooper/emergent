describe 'StoryController', ->
  Story = require('../../../data-store').models.Story

  beforeEach ->
    @sandbox = sinon.sandbox.create()

  afterEach ->
    @sandbox.restore()

  mockStory = (options) -> Story.build(options)

  describe '#index', ->
    req = ->
      supertest(app)
        .get('/stories')
        .set('Accept', 'application/json')

    beforeEach ->
      @sandbox.stub(Story, 'findAll').returns(Promise.resolve([]))

    it 'should return JSON with a JSONish request', (done) ->
      req()
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect([])
        .expect(200)
        .end(done)

    describe 'when there are Stories', ->
      beforeEach ->
        Story.findAll.returns(Promise.resolve([
          mockStory(slug: 'slug-a')
          mockStory(slug: 'slug-b')
        ]))

      it 'should return the stories', (done) ->
        req()
          .expect (res) ->
            res.body.map((x) -> x.slug).should.deep.equal([ 'slug-a', 'slug-b' ])
            undefined
          .end(done)

  describe '#find', ->
    req = (slug) ->
      supertest(app)
        .get("/stories/#{slug}")
        .set('Accept', 'application/json')

    beforeEach ->
      @sandbox.stub(Story, 'find').returns(Promise.resolve(mockStory(slug: 'slug-a')))

    it 'should return the story by slug', (done) ->
      req('slug-a')
        .expect(200)
        .expect (res) ->
          Story.find.should.have.been.calledWith(where: { slug: 'slug-a' })
          res.body.slug.should.equal('slug-a')
          undefined
        .end(done)

    it 'should return a 404 for a missing story', (done) ->
      Story.find.returns(Promise.resolve(null))
      req('invalid-slug')
        .expect(404)
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

    beforeEach ->
      @sandbox.stub(Story, 'create')

    it 'should create the story', (done) ->
      Story.create.returns(Promise.resolve(mockStory(slug: 'slug-a')))
      req().end ->
        Story.create.should.have.been.called
        Story.create.lastCall.args[0].slug.should.eq('slug-a')
        Story.create.lastCall.args[1].should.eq('user@example.org')
        done()

    it 'should return a JSON response with the created story', (done) ->
      Story.create.returns(Promise.resolve(mockStory(slug: 'slug-a')))
      req()
        .expect(200)
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect (res) ->
          res.body.slug.should.equal('slug-a')
          undefined
        .end(done)

    it 'should return a 400 error when creating fails', (done) ->
      Story.create.returns(Promise.reject(message: 'oh no'))
      req(slug: '')
        .expect(400)
        .expect('Content-Type', 'application/json; charset=utf-8')
        .end(done)

  describe '#destroy', ->
    req = (slug) ->
      supertest(app)
        .delete("/stories/#{slug}")
        .set('Accept', 'application/json')

    reqPromise = (slug) ->
      r = req(slug)
      Promise.promisify(r.end, r)()

    beforeEach ->
      @sandbox.stub(Story, 'destroy').returns(Promise.resolve(undefined))

    it 'should return OK', ->
      reqPromise('foo')
        .should.eventually.contain(status: 200)

    it 'should destroy the story', ->
      reqPromise('foo')
        .then(-> Story.destroy.should.have.been.calledWith(slug: 'foo'))

    it 'should return 500 error if the story cannot be destroyed', (done) ->
      Story.destroy.returns(Promise.reject('foo'))
      req('foo')
        .expect(500)
        .end(done)

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

    reqPromise = (object, slug) ->
      r = req(object, slug)
      Promise.promisify(r.end, r)()

    beforeEach ->
      @sandbox.stub(Story, 'find')
      @sandbox.stub(Story, 'update')
      Story.find.returns(Promise.resolve(mockStory(slug: 'slug-a', description: 'foo')))
      Story.update.returns(Promise.resolve(mockStory(slug: 'slug-a', description: 'bar')))

    it 'should return 404 when the object does not exist', ->
      Story.find.returns(Promise.resolve(null))
      reqPromise(slug: 'slug-b')
        .then (x) ->
          Story.find.should.have.been.calledWith(where: { slug: 'slug-b' })
          x
        .should.eventually.contain(status: 404)

    it 'should return 400 when the slug is wrong', (done) ->
      supertest(app)
        .put('/stories/slug-a')
        .set('Accept', 'application/json')
        .send(slug: 'slug-b')
        .expect(400, done)

    describe 'with a valid request', ->
      beforeEach ->
        @response = reqPromise(slug: 'slug-a', description: 'bar')

      it 'should return 200 OK', ->
        @response.should.eventually.contain(status: 200)

      it 'should update the object in question', (done) ->
        Story.update.should.have.been.called
        args = Story.update.lastCall.args
        args[0].slug.should.eq('slug-a')
        args[1].description.should.eq('bar')
        args[2].should.eq('user@example.org')
        done()

      it 'should return the updated object', ->
        @response.then((res) -> res.body)
          .should.eventually.contain(description: 'bar')
