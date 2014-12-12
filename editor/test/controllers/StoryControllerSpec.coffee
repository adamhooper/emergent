describe 'StoryController', ->
  models = require('../../../data-store').models
  Story = models.Story
  Category = models.Category
  CategoryStory = models.CategoryStory
  StoryTag = models.StoryTag
  Tag = models.Tag

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
          .spread (c1, c2) => Promise.all([
            CategoryStory.create({ categoryId: c1.id, storyId: @story1.id }, 'editor@example.org')
            CategoryStory.create({ categoryId: c1.id, storyId: @story2.id }, 'editor@example.org')
            CategoryStory.create({ categoryId: c2.id, storyId: @story1.id }, 'editor@example.org')
          ])
          .then -> req()
          .tap (res) ->
            expect(res.body).to.have.property('length', 2)
            stories = res.body.sort((a, b) -> a.slug.localeCompare(b.slug))
            expect(stories[0].categories).to.exist
            expect(stories[0].categories).to.deep.eq([ 'bar', 'foo' ])
            expect(stories[1].categories).to.deep.eq([ 'foo' ])

      it 'should include tags', ->
        Promise.all([
          Tag.create({ name: 'foo' }, 'admin@example.org')
          Tag.create({ name: 'bar' }, 'admin@example.org')
        ])
          .spread (t1, t2) => Promise.all([
            StoryTag.create({ tagId: t1.id, storyId: @story1.id }, 'editor@example.org')
            StoryTag.create({ tagId: t1.id, storyId: @story2.id }, 'editor@example.org')
            StoryTag.create({ tagId: t2.id, storyId: @story1.id }, 'editor@example.org')
          ])
          .then -> req()
          .tap (res) ->
            expect(res.body).to.have.property('length', 2)
            stories = res.body.sort((a, b) -> a.slug.localeCompare(b.slug))
            expect(stories[0].tags).to.exist
            expect(stories[0].tags).to.deep.eq([ 'bar', 'foo' ])
            expect(stories[1].tags).to.deep.eq([ 'foo' ])

  describe '#find', ->
    req = (slug) ->
      ret = supertest(app).get("/stories/#{slug}").set('Accept', 'application/json')
      Promise.promisify(ret.end, ret)()

    beforeEach ->
      Story.create(mockStory(slug: 'slug-a'), 'user-a@example.org')
        .tap (s) => @story = s

    it 'should return the story by slug', ->
      req('slug-a')
        .tap (res) ->
          expect(res.statusCode).to.eq(200)
          expect(res.body).to.have.property('slug', 'slug-a')

    it 'should return a 404 for a missing story', ->
      req('invalid-slug')
        .tap (res) -> expect(res.statusCode).to.eq(404)

    it 'should include an empty Array of categories when there are none', ->
      req('slug-a')
        .tap (res) ->
          expect(res.body.categories).to.deep.eq([])

    it 'should include an Array of category names', ->
      Promise.all([
        Category.create({ name: 'foo' }, 'admin@example.org')
        Category.create({ name: 'bar' }, 'admin@example.org')
      ])
        .spread (c1, c2) => Promise.all([
          CategoryStory.create({ categoryId: c1.id, storyId: @story.id }, 'admin@example.org')
          CategoryStory.create({ categoryId: c2.id, storyId: @story.id }, 'admin@example.org')
        ])
        .then -> req('slug-a')
        .tap (res) ->
          expect(res.body.categories.sort()).to.deep.eq([ 'bar', 'foo' ])

    it 'should include an Array of tag names', ->
      Promise.all([
        Tag.create({ name: 'foo' }, 'admin@example.org')
        Tag.create({ name: 'bar' }, 'admin@example.org')
      ])
        .spread (c1, c2) => Promise.all([
          StoryTag.create({ tagId: c1.id, storyId: @story.id }, 'admin@example.org')
          StoryTag.create({ tagId: c2.id, storyId: @story.id }, 'admin@example.org')
        ])
        .then -> req('slug-a')
        .tap (res) ->
          expect(res.body.tags.sort()).to.deep.eq([ 'bar', 'foo' ])

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

    describe 'with Categories', ->
      beforeEach -> Promise.all([
        Category.create({ name: 'foo' }, 'admin@example.org')
        Category.create({ name: 'bar' }, 'admin@example.org')
        Category.create({ name: 'baz' }, 'admin@example.org')
      ]).spread (foo, bar, baz) => @categoryFoo = foo; @categoryBar = bar; @categoryBaz = baz

      it 'should add and return the specified categories', ->
        req(slug: 'slug-a', categories: [ 'foo', 'bar' ])
          .tap (res) -> expect(res.body.categories?.sort()).to.deep.eq([ 'bar', 'foo' ])
          .then -> Story.find(where: { slug: 'slug-a' })
          .then (story) => Promise.all([
            CategoryStory.find(where: { storyId: story.id, categoryId: @categoryFoo.id })
            CategoryStory.find(where: { storyId: story.id, categoryId: @categoryBar.id })
            CategoryStory.find(where: { storyId: story.id, categoryId: @categoryBaz.id })
          ])
          .spread (foo, bar, baz) ->
            expect(foo).to.exist
            expect(bar).to.exist
            expect(baz).not.to.exist

      it 'should nix nonexistent categories', ->
        req(slug: 'slug-a', categories: [ 'foo', 'foo2' ])
          .tap (res) -> expect(res.body.categories?.sort()).to.deep.eq([ 'foo' ])
          .then -> Story.find(where: { slug: 'slug-a' })
            .then (story) => Promise.all([
              CategoryStory.find(where: { storyId: story.id, categoryId: @categoryFoo.id })
              CategoryStory.find(where: { storyId: story.id, categoryId: @categoryBar.id })
              CategoryStory.find(where: { storyId: story.id, categoryId: @categoryBaz.id })
            ])
            .spread (foo, bar, baz) ->
              expect(foo).to.exist
              expect(bar).not.to.exist
              expect(baz).not.to.exist
          .then -> Category.find(where: { name: 'foo2' })
            .tap (category) -> expect(category).not.to.exist

    describe 'with Tags', ->
      beforeEach -> Promise.all([
        Tag.create({ name: 'foo' }, 'admin@example.org')
        Tag.create({ name: 'bar' }, 'admin@example.org')
        Tag.create({ name: 'baz' }, 'admin@example.org')
      ]).spread (foo, bar, baz) => @tagFoo = foo; @tagBar = bar; @tagBaz = baz

      it 'should add and return tags when they already exist', ->
        req(slug: 'slug-a', tags: [ 'foo', 'bar' ])
          .tap (res) -> expect(res.body.tags.sort()).to.deep.eq([ 'bar', 'foo' ])
          .then -> Story.find(where: { slug: 'slug-a' })
          .then (story) => Promise.all([
            StoryTag.find(where: { storyId: story.id, tagId: @tagFoo.id })
            StoryTag.find(where: { storyId: story.id, tagId: @tagBar.id })
            StoryTag.find(where: { storyId: story.id, tagId: @tagBaz.id })
          ])
          .spread (foo, bar, baz) ->
            expect(foo).to.exist
            expect(bar).to.exist
            expect(baz).not.to.exist

      it 'should create new tags', ->
        req(slug: 'slug-a', tags: [ 'foo', 'foo2' ])
          .tap (res) -> expect(res.body.tags?.sort()).to.deep.eq([ 'foo', 'foo2' ])
          .then -> Promise.all([
            Story.find(where: { slug: 'slug-a' })
            Tag.findAll(where: { name: 'foo' })
            Tag.findAll(where: { name: 'foo2' })
          ])
          .spread (story, foo, foo2) ->
            expect(foo.length).to.eq(1)
            expect(foo2.length).to.eq(1)

            StoryTag.find(where: { storyId: story.id, tagId: foo2[0].id })
          .then (st) -> expect(st).to.exist

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

    it 'should destroy CategoryStories as well', ->
      Promise.all([
        Story.create(mockStory(slug: 'slug-a'), 'user-a@example.org')
        Category.create({ name: 'foo' }, 'admin@example.org')
      ])
        .spread (story, category) ->
          CategoryStory.create({ categoryId: category.id, storyId: story.id }, 'user-a@example.org')
        .tap ->
          req('slug-a')
        .then (categoryStory) -> Promise.all([
          Category.find(categoryStory.categoryId)
          CategoryStory.findAll(where: { storyId: categoryStory.storyId })
        ])
        .spread (category, categoryStories) ->
          expect(category).to.exist
          expect(categoryStories).to.have.property('length', 0)

    describe 'with StoryTags', ->
      beforeEach ->
        Promise.all([
          Story.create(mockStory(slug: 'slug-a'), 'user-a@example.org')
          Story.create(mockStory(slug: 'other'), 'user-a@example.org')
          Tag.create({ name: 'foo' }, 'editor@example.org')
          Tag.create({ name: 'bar' }, 'editor@example.org')
        ])
          .spread (story, otherStory, tag1, tag2) =>
            @story = story
            @otherStory = otherStory
            @tag1 = tag1
            @tag2 = tag2
            Promise.all([
              StoryTag.create({ tagId: @tag1.id, storyId: @story.id }, 'editor@example.org')
              StoryTag.create({ tagId: @tag1.id, storyId: @otherStory.id }, 'editor@example.org')
              StoryTag.create({ tagId: @tag2.id, storyId: @story.id }, 'editor@example.org')
            ])

      it 'should delete the StoryTags', ->
        req(@story.slug)
          .then => StoryTag.findAll(where: { storyId: @story.id })
          .then (r) => expect(r).to.have.property('length', 0)

      it 'should delete no-longer-used Tags', ->
        req(@story.slug)
          .then => Promise.all([
            Tag.find(@tag1.id)
            Tag.find(@tag2.id)
          ])
          .spread (tag1, tag2) =>
            expect(tag1).to.exist
            expect(tag2).to.not.exist

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
        .tap (s) => @story = s

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

    describe 'with Categories', ->
      beforeEach -> Promise.all([
        Category.create({ name: 'foo' }, 'admin@example.org')
        Category.create({ name: 'bar' }, 'admin@example.org')
        Category.create({ name: 'baz' }, 'admin@example.org')
      ]).spread (foo, bar, baz) => @categoryFoo = foo; @categoryBar = bar; @categoryBaz = baz

      it 'should add and return the specified categories', ->
        req(slug: 'slug-a', categories: [ 'foo', 'bar' ])
          .tap (res) -> expect(res.body.categories?.sort()).to.deep.eq([ 'bar', 'foo' ])
          .then => Promise.all([
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryFoo.id })
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryBar.id })
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryBaz.id })
          ])
          .spread (foo, bar, baz) ->
            expect(foo).to.exist
            expect(bar).to.exist
            expect(baz).not.to.exist

      it 'should nix nonexistent categories', ->
        req(slug: 'slug-a', categories: [ 'foo', 'foo2' ])
          .tap (res) -> expect(res.body.categories?.sort()).to.deep.eq([ 'foo' ])
          .then => Promise.all([
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryFoo.id })
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryBar.id })
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryBaz.id })
          ])
          .spread (foo, bar, baz) ->
            expect(foo).to.exist
            expect(bar).not.to.exist
            expect(baz).not.to.exist
          .then -> Category.find(where: { name: 'foo2' })
          .tap (category) -> expect(category).not.to.exist

      it 'should remove categories that are removed', ->
        CategoryStory.create({ categoryId: @categoryFoo.id, storyId: @story.id }, 'admin@example.org')
          .then -> req(slug: 'slug-a', categories: [ 'bar', 'baz' ])
          .tap (res) -> expect(res.body.categories?.sort()).to.deep.eq([ 'bar', 'baz' ])
          .then => Promise.all([
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryFoo.id })
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryBar.id })
            CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryBaz.id })
          ])
          .spread (foo, bar, baz) ->
            expect(foo).not.to.exist
            expect(bar).to.exist
            expect(baz).to.exist
          .then -> Category.find(where: { name: 'foo' })
          .tap (category) -> expect(category).to.exist

      it 'should remove all categories', ->
        CategoryStory.create({ categoryId: @categoryFoo.id, storyId: @story.id }, 'admin@example.org')
          .then -> req(slug: 'slug-a', categories: [])
          .tap (res) -> expect(res.body.categories).to.deep.eq([])
          .then => CategoryStory.find(where: { storyId: @story.id, categoryId: @categoryFoo.id })
          .tap (foo) -> expect(foo).not.to.exist

    describe 'with Tags', ->
      # Tagged ["foo"] by default
      beforeEach ->
        Promise.all([
          Tag.create({ name: 'foo' }, 'admin@example.org')
          Tag.create({ name: 'bar' }, 'admin@example.org')
          Tag.create({ name: 'baz' }, 'admin@example.org')
        ])
          .tap ([foo, bar, baz]) => @tagFoo = foo; @tagBar = bar; @tagBaz = baz
          .tap => StoryTag.create({ storyId: @story.id, tagId: @tagFoo.id }, 'admin@example.org')

      it 'should add and return tags when they already exist', ->
        req(slug: 'slug-a', tags: [ 'foo', 'bar', 'baz' ])
          .tap (res) -> expect(res.body.tags.sort()).to.deep.eq([ 'bar', 'baz', 'foo' ])
          .then -> Story.find(where: { slug: 'slug-a' })
          .then (story) => Promise.all([
            StoryTag.find(where: { storyId: story.id, tagId: @tagFoo.id })
            StoryTag.find(where: { storyId: story.id, tagId: @tagBar.id })
            StoryTag.find(where: { storyId: story.id, tagId: @tagBaz.id })
          ])
          .tap ([foo, bar, baz]) ->
            expect(foo).to.exist
            expect(bar).to.exist
            expect(baz).to.exist
          .then -> Tag.findAll()
          .tap (tags) -> expect(tags.length).to.eq(3)

      it 'should create new tags', ->
        req(slug: 'slug-a', tags: [ 'foo', 'foo2' ])
          .tap (res) -> expect(res.body.tags?.sort()).to.deep.eq([ 'foo', 'foo2' ])
          .then -> Promise.all([
            Story.find(where: { slug: 'slug-a' })
            Tag.findAll(where: { name: [ 'foo', 'foo2' ] })
          ])
          .tap ([story, tags]) -> expect(tags.length).to.eq(2)
          .then ([story, tags]) -> StoryTag.findAll(where: { storyId: story.id, tagId: (t.id for t in tags) })
          .tap (st) -> expect(st.length).to.eq(2)

      it 'should delete tags when they have no more StoryTag entries', ->
        req(slug: 'slug-a', tags: [ 'bar', 'baz' ])
          .then => Promise.all([
            Tag.find(@tagFoo.id)
            StoryTag.findAll(where: { tagId: @tagFoo.id })
          ])
          .tap ([tag, storyTags]) ->
            expect(tag).not.to.exist
            expect(storyTags).to.have.property('length', 0)
