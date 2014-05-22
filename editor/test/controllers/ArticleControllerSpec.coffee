ObjectID = require('../../node_modules/sails-mongo/node_modules/mongodb/index').ObjectID

describe 'ArticleController', ->
  model = -> sails.models.article

  mockStoryInDb = (options) ->
    _.extend(
      id: new ObjectID()
      slug: 'slug-a'
      headline: 'headline'
      description: 'foo'
      createdBy: 'foo@example.org'
      updatedBy: 'foo@example.org'
    , options)

  mockArticleInDb = (options) ->
    _.extend(
      id: new ObjectID()
      url: null
      createdBy: 'foo@example.org'
      updatedBy: 'foo@example.org'
    , options)

  mockArticle = (options) ->
    _.extend(
      url: null
    , options)

  beforeEach ->
    @Story = sails.models.story
    @Article = sails.models.article

    @Story.create(mockStoryInDb(slug: 'slug-a'))
      .then (story) => @story1 = story

  describe '#index', ->
    req = ->
      supertest(app)
        .get('/stories/slug-a/articles')
        .set('Accept', 'application/json')

    it 'should return JSON with a JSONish request', (done) ->
      req()
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect([])
        .expect(200)
        .end(done)

    it 'should return 404 when the story does not exist', (done) ->
      supertest(app)
        .get('/stories/wrong-slug/articles')
        .set('Accept', 'application/json')
        .expect(404)
        .end(done)

    describe 'when there are Articles', ->
      beforeEach ->
        @article1 = null
        @article2 = null

        Q.all([
          @Article.create(mockArticleInDb(url: 'http://example.org'))
          @Article.create(mockArticleInDb(url: 'http://example2.org'))
        ])
          .spread (x, y) =>
            @article1 = x
            @article2 = y
          .then =>
            Q.all([
              sails.models.article_story.create(storyId: @story1.id, articleId: @article1.id)
              sails.models.article_story.create(storyId: @story1.id, articleId: @article2.id)
            ])
          .fail (e) -> console.log(e)
          .done()

      it 'should return the articles', (done) ->
        req()
          .expect (res) ->
            res.body.map((x) -> x.url).should.deep.equal(['http://example.org', 'http://example2.org'])
            undefined
          .end(done)

  describe '#create', ->
    req = (options) ->
      object = mockArticle(options)
      supertest(app)
        .post('/stories/slug-a/articles')
        .set('Accept', 'application/json')
        .send(object)

    reqPromise = (options) ->
      Q.npost(req(options), 'end')

    reqAndFetchFromDb = (options) ->
      throw 'Must set options.url' if !options.url?
      Q.npost(req(options), 'end')
        .then -> model().findOne(url: options.url)

    it 'should return a 404 when the Story does not exist', (done) ->
      supertest(app)
        .post('/stories/invalid-slug/articles')
        .set('Accept', 'application/json')
        .send(mockArticle(url: 'http://example.org'))
        .expect(404)
        .end(done)

    it 'should return a JSON response with the object', (done) ->
      req(url: 'http://example.org')
        .expect(200)
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect (res) ->
          res.body.url.should.equal('http://example.org')
          undefined
        .end(done)

    it 'should store the article', ->
      reqAndFetchFromDb(url: 'http://example.org')
        .should.eventually.contain(url: 'http://example.org')

    describe 'when an article is already there', ->
      beforeEach ->
        @url = 'http://example.org'
        reqPromise(url: @url)

      it 'should not store a duplicate article', ->
        reqPromise(url: @url)
          .then((res) => @Article.find())
          .then((x) -> x.length)
          .should.eventually.equal(1)

      it 'should not store a duplicate association', ->
        reqPromise(url: @url)
          .then(-> sails.models.article_story.find(where: null))
          .then((x) -> x.length)
          .should.eventually.equal(1)

      it 'should return the Article', (done) ->
        req(url: @url)
          .expect(200)
          .expect (res) =>
            res.body.url.should.equal(@url)
            undefined
          .end(done)

    it 'should add the user to the story as createdBy and updatedBy', ->
      reqAndFetchFromDb(url: 'http://example.org')
        .should.eventually.contain(createdBy: 'user@example.org', updatedBy: 'user@example.org')

    it 'should not let the user manually set createdBy or updatedBy', ->
      Q.all([
        Q.npost(req(url: 'http://example.org', createdBy: 'user2@example.org'), 'end')
          .then((x) -> x.body)
          .should.eventually.contain(createdBy: 'user@example.org')
        Q.npost(req(url: 'http://example.org', updatedBy: 'user2@example.org'), 'end')
          .then((x) -> x.body)
          .should.eventually.contain(updatedBy: 'user@example.org')
      ])

    it 'should return a JSON error when the URL is invalid', (done) ->
      req(url: 'htt://example.org')
        .expect(400)
        .expect (res) ->
          Object.keys(res.body.invalidAttributes).should.deep.equal(['url'])
          undefined
        .end(done)

  describe '#update', ->
    req = (options) ->
      throw 'Must set options.url' if !options.url?
      throw 'Must set options.id' if !options.id?
      object = mockArticle(options)
      supertest(app)
        .put("/stories/slug-a/articles/#{object.id}")
        .set('Accept', 'application/json')
        .send(object)

    reqPromise = (options) ->
      Q.npost(req(options), 'end')

    reqAndFetchFromDb = (options) ->
      Q.npost(req(options), 'end')
        .then -> model().findOne(url: options.url)

    beforeEach ->
      @article1 = null

      @Article.create(mockArticleInDb(url: 'http://example.org'))
        .then (article) => @article1 = article
        .then (article) => sails.models.article_story.create(articleId: article.id, storyId: @story1.id)

    it 'should return a 404 when the Story does not exist', (done) ->
      supertest(app)
        .put("/stories/invalid-slug/articles/#{@article1.id}")
        .set('Accept', 'application/json')
        .send(mockArticle(url: 'http://example.org'))
        .expect(404)
        .end(done)

    it 'should return a 404 when the Article does not exist', (done) ->
      req(id: "not#{@article1.id}", url: 'http://example.org')
        .expect(404)
        .end(done)

    it 'should return a JSON response with the changed Article', (done) ->
      req(id: @article1.id, url: 'http://example2.org')
        .expect(200)
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect (res) ->
          res.body.url.should.equal('http://example2.org')
          undefined
        .end(done)

    it 'should store the article', ->
      reqAndFetchFromDb(id: @article1.id, url: 'http://example2.org')
        .should.eventually.contain(url: 'http://example2.org')

    it 'should add the user to the story as updatedBy', ->
      reqAndFetchFromDb(id: @article1.id, url: 'http://example2.org')
        .should.eventually.contain(createdBy: 'foo@example.org', updatedBy: 'user@example.org')

    it 'should not let the user manually set createdBy or updatedBy', ->
      Q.all([
        Q.npost(req(id: @article1.id, url: 'http://example2.org', createdBy: 'user2@example.org'), 'end')
          .then((x) -> x.body)
          .should.eventually.contain(createdBy: 'foo@example.org')
        Q.npost(req(id: @article1.id, url: 'http://example2.org', updatedBy: 'user2@example.org'), 'end')
          .then((x) -> x.body)
          .should.eventually.contain(updatedBy: 'user@example.org')
      ])

    it 'should return a JSON error when the URL is invalid', (done) ->
      req(id: @article1.id, url: 'htt://example.org')
        .expect(400)
        .expect (res) ->
          Object.keys(res.body.invalidAttributes).should.deep.equal(['url'])
          undefined
        .end(done)

  describe '#destroy', ->
    req = (slug, id) ->
      supertest(app)
        .delete("/stories/#{slug}/articles/#{id}")
        .set('Accept', 'application/json')

    reqPromise = (slug, id) ->
      Q.npost(req(slug, id), 'end')

    beforeEach ->
      @article1 = null

      @Article.create(mockArticleInDb(url: 'http://example.org'))
        .then (article) => @article1 = article
        .then (article) => sails.models.article_story.create(articleId: article.id, storyId: @story1.id)

    it 'should return 404 when the Story does not exist', ->
      reqPromise('some-slug', 'abcdef')
        .should.eventually.contain(status: 404)

    it 'should return 200 OK when the Article does not exist', ->
      reqPromise(@story1.slug, 'abcdef')
        .should.eventually.contain(status: 200)

    it 'should return 200 OK when the Article exists', ->
      reqPromise(@story1.slug, @article1.id)
        .should.eventually.contain(status: 200)

    it 'should leave the Article in the database', ->
      reqPromise(@story1.slug, @article1.id)
        .then(=> @Article.findOne(id: @article1.id))
        .should.eventually.exist

    it 'should delete the association', ->
      reqPromise(@story1.slug, @article1.id)
        .then(-> sails.models.article_story.find(where: null))
        .then((x) -> x.length)
        .should.eventually.equal(0)
