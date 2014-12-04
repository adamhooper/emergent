describe 'StoryController', ->
  models = require('../../../data-store').models
  Story = models.Story
  Category = models.Category
  CategoryStory = models.CategoryStory

  mockStory = (options) ->
    _.extend({
      headline: 'headline'
      description: 'description'
    }, options)

  describe '#index', ->
    req = ->
      ret = supertest(app).get('/stories').set('Accept', 'application/json')
      Promise.promisify(ret.end, ret)()

    it 'should return JSON with a JSONish request', ->
      req()
        .tap (res) =>
          expect(res.statusCode).to.eq(200)
          expect(res.headers['content-type']).to.equal('application/json; charset=utf-8')
          expect(res.body).to.deep.eq([])

    describe 'when there are Stories', ->
      beforeEach ->
        Promise.all([
          Story.create(mockStory(slug: 'slug-a'), 'user-a@example.org')
          Story.create(mockStory(slug: 'slug-b'), 'user-a@example.org')
        ])
          .spread (s1, s2) => @story1 = s1; @story2 = s2

      it 'should return the stories', ->
        req()
          .tap (res) ->
            res.body.map((x) -> x.slug).sort().should.deep.equal([ 'slug-a', 'slug-b' ])

      it 'should include categories', ->
        Promise.all([
          Category.create({ name: 'foo' }, 'admin@example.org')
          Category.create({ name: 'bar' }, 'admin@example.org')
        ])
          .spread (c1, c2) => @category1 = c1; @category2 = c2
          .then => Promise.all([
            CategoryStory.create({ categoryId: @category1.id, storyId: @story1.id }, 'editor@example.org')
            CategoryStory.create({ categoryId: @category1.id, storyId: @story2.id }, 'editor@example.org')
            CategoryStory.create({ categoryId: @category2.id, storyId: @story1.id }, 'editor@example.org')
          ])
          .then -> req()
          .tap (res) ->
            expect(res.body).to.have.property('length', 2)
            stories = res.body.sort((a, b) -> a.slug - b.slug)
            expect(stories[0].categories).to.exist
            expect(stories[0].categories.sort()).to.deep.eq([ 'bar', 'foo' ])
            expect(stories[1].categories).to.deep.eq([ 'foo' ])

  describe '#find', ->
    req = (slug) ->
      ret = supertest(app).get("/stories/#{slug}").set('Accept', 'application/json')
      Promise.promisify(ret.end, ret)()

    beforeEach ->
      Story.create(mockStory(slug: 'slug-a'), 'user-a@example.org')

    it 'should return the story by slug', ->
      req('slug-a')
        .tap (res) ->
          expect(res.statusCode).to.eq(200)
          expect(res.body).to.have.property('slug', 'slug-a')

    it 'should return a 404 for a missing story', ->
      req('invalid-slug')
        .tap (res) -> expect(res.statusCode).to.eq(404)

  describe '#create', ->
    req = (object) ->
      object ?= {}
      object.slug ?= 'slug-a'
      object.headline ?= 'headline'

      ret = supertest(app)
        .post('/stories')
        .set('Accept', 'application/json')
        .send(object)

      Promise.promisify(ret.end, ret)()

    it 'should create the story in the database', ->
      req(slug: 'slug-a')
        .then -> Story.find(where: { slug: 'slug-a' })
        .tap (story) ->
          expect(story).to.exist
          expect(story).to.have.property('slug', 'slug-a')
          expect(story).to.have.property('createdBy', 'user@example.org')

    it 'should return a JSON response with the created story', ->
      req(slug: 'slug-a')
        .tap (res) ->
          expect(res.statusCode).to.eq(200)
          expect(res.headers).to.have.property('content-type', 'application/json; charset=utf-8')
          expect(res.body).to.have.property('slug', 'slug-a')

    it 'should return a 400 error when creating fails', ->
      Story.create(mockStory(slug: 'slug-a'), 'user1@example.org')
        .then -> req(slug: 'slug-a')
        .tap (res) ->
          expect(res.statusCode).to.eq(400)
          expect(res.headers).to.have.property('content-type', 'application/json; charset=utf-8')

  describe '#destroy', ->
    req = (slug) ->
      ret = supertest(app)
        .delete("/stories/#{slug}")
        .set('Accept', 'application/json')
      Promise.promisify(ret.end, ret)()

    it 'should return OK even when the story does not exist', ->
      req('blargh')
        .tap (res) -> expect(res.statusCode).to.eq(200)

    it 'should destroy the story from the database', ->
      Story.create(mockStory(slug: 'slug-a'), 'user-a@example.org')
        .then -> req('slug-a')
        .then -> Story.find(where: { slug: 'slug-a' })
        .tap (s) -> expect(s).not.to.exist

  describe '#update', ->
    req = (object, slug) ->
      slug ?= object.slug
      toSend = {}
      for k, v of object
        toSend[k] = v
      delete toSend.slug
      ret = supertest(app)
        .put("/stories/#{slug}")
        .set('Accept', 'application/json')
        .send(toSend)
      Promise.promisify(ret.end, ret)()

    beforeEach ->
      Story.create(mockStory(slug: 'slug-a', description: 'foo'), 'user-a@example.org')

    it 'should return 404 when the object does not exist', ->
      req(slug: 'slug-b')
        .tap (res) ->
          expect(res.statusCode).to.eq(404)

    it 'should never update the slug', ->
      req({ slug: 'slug-b' }, 'slug-a')
        .tap (res) -> expect(res.body).to.have.property('slug', 'slug-a')
        .then(-> Promise.all([
          Story.find(where: { slug: 'slug-a' })
          Story.find(where: { slug: 'slug-b' })
        ]))
        .spread (a, b) ->
          expect(a).to.exist
          expect(b).not.to.exist

    describe 'with a valid request', ->
      it 'should return 200 OK with the updated object', ->
        req(slug: 'slug-a', description: 'bar')
          .tap (res) ->
            expect(res.statusCode).to.eq(200)
            expect(res.body).to.have.property('slug', 'slug-a')
            expect(res.body).to.have.property('description', 'bar')

      it 'should update the object in question', ->
        req(slug: 'slug-a', description: 'bar')
          .then -> Story.find(where: { slug: 'slug-a' })
          .tap (story) ->
            expect(story).to.have.property('slug', 'slug-a')
            expect(story).to.have.property('description', 'bar')
            expect(story).to.have.property('updatedBy', 'user@example.org')
