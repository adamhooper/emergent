Promise = require('bluebird')

Article = global.models.Article
Story = global.models.Story
Url = global.models.Url
UrlVersion = global.models.UrlVersion
ArticleVersion = global.models.ArticleVersion

describe 'ArticleController', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @sandbox.stub(global.urlJobQueue, 'queue').callsArg(1)

    Story.create({ slug: 'slug-a', headline: 'headline', description: 'foo' }, 'user@example.org')
      .then (story) => @story1 = story

  afterEach ->
    @sandbox.restore()

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

        # Create Articles in series, so they stay in this order
        Url.create({ url: 'http://example.org' }, 'user@example.org')
          .then((u) => Article.create({ storyId: @story1.id, urlId: u.id }, 'user@example.org'))
          .then((a) => @article1 = a)
          .then(-> Url.create({ url: 'http://example2.org' }, 'user@example.org'))
          .then((u) => Article.create({ storyId: @story1.id, urlId: u.id }, 'user@example.org'))
          .then((a) => @article2 = a)

      it 'should return the Articles', (done) ->
        req()
          .expect (res) ->
            res.body.map((x) -> x.url).should.deep.equal(['http://example.org', 'http://example2.org'])
            undefined
          .end(done)

  describe '#create', ->
    req = (object) ->
      supertest(app)
        .post('/stories/slug-a/articles')
        .set('Accept', 'application/json')
        .send(object)

    reqPromise = (object) ->
      r = req(object)
      Promise.promisify(r.end, r)()

    reqAndFetchFromDb = (object) ->
      throw 'Must set object.url' if !object.url?
      reqPromise(object)
        .catch((e) -> console.error(e, e.stack))
        .then(-> Promise.all([
          Article.find(where: {})
          Url.find(where: {})
        ]))

    it 'should return a 404 when the Story does not exist', (done) ->
      supertest(app)
        .post('/stories/invalid-slug/articles')
        .set('Accept', 'application/json')
        .send(url: 'http://example.org')
        .expect(404)
        .end(done)

    it 'should return a JSON response with the Article', (done) ->
      req(url: 'http://example.org')
        .expect(201)
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect (res) ->
          expect(res.body).to.have.property('url', 'http://example.org')
          undefined
        .end(done)

    it 'should store the Article', ->
      reqAndFetchFromDb(url: 'http://example.org')
        .spread (article, url) =>
          expect(url).to.have.property('url', 'http://example.org')
          expect(article).to.have.property('storyId', @story1.id)
          expect(article).to.have.property('urlId', url.id)

    it 'should queue the url for fetching', ->
      reqPromise(url: 'http://example.org')
        .then(-> Url.find(where: {}))
        .then((u) -> u.id)
        .then (urlId) -> expect(global.urlJobQueue.queue).to.have.been.calledWith(id: urlId, url: 'http://example.org')

    it 'should not store a duplicate Url', ->
      url = null

      Url.create(url: 'http://example.org')
        .then((u) -> url = u)
        .then(-> reqPromise(url: 'http://example.org'))
        .tap((r) -> expect(r.status).to.eq(201))
        .tap((r) -> expect(r).to.have.deep.property('res.body.url', 'http://example.org'))
        .then(-> Url.findAll())
        .then((urls) -> expect(urls).to.have.property('length', 1))
        .then -> expect(global.urlJobQueue.queue).not.to.have.been.called

    it 'should not store a duplicate Article', ->
      url = null
      article = null

      Url.create({ url: 'http://example.org' }, 'user@example.org')
        .then((u) -> url = u)
        .then(=> Article.create({ storyId: @story1.id, urlId: url.id }, 'user@example.org'))
        .then((a) -> article = a)
        .then(-> reqPromise(url: 'http://example.org'))
        .tap((r) -> expect(r.status).to.eq(201))
        .tap((r) -> expect(r).to.have.deep.property('res.body.id', article.id))
        .then(-> Article.findAll())
        .then((articles) -> expect(articles).to.have.property('length', 1))

    it 'should add the user to the Article as createdBy', ->
      reqAndFetchFromDb(url: 'http://example.org')
        .spread (article, url) ->
          expect(article).to.have.property('createdBy', 'user@example.org')

    it 'should return a JSON error when the URL is invalid', (done) ->
      req(url: 'htt://example.org')
        .expect(400)
        .end(done)

    describe 'when there is an existing Article for the URL on another Story', ->
      beforeEach ->
        Promise.all([
          Story.create({ slug: 'slug-b', headline: 'headline b', description: 'description b' }, 'user@example.org')
          Url.create({ url: 'http://example.org' }, 'user@example.org')
        ])
          .spread (s, u) =>
            Promise.all([
              Article.create({ storyId: s.id, urlId: u.id }, 'user@example.org')
              UrlVersion.create({ urlId: u.id, source: 'source', byline: 'byline', headline: 'headline', body: 'body' }, 'user@example.org')
            ])
              .then ([a, uv]) =>
                @existingArticle = a
                @existingUrlVersion = uv
                ArticleVersion.create({ urlVersionId: uv.id, articleId: a.id }, 'user@example.org')
                  .then (av) -> @existingArticleVersion = av
          .catch (e) -> console.warn(e)

      it 'should succeed', ->
        reqPromise(url: 'http://example.org')
          .tap (res) -> expect(res.statusCode).to.eq(201)

      it 'should not create another UrlVersion', ->
        reqPromise(url: 'http://example.org')
          .then -> UrlVersion.findAll()
          .tap (arr) =>
            expect(arr.length).to.eq(1)
            expect(arr[0].id).to.eq(@existingUrlVersion.id)

      it 'should create another ArticleVersion', ->
        reqPromise(url: 'http://example.org')
          .then -> ArticleVersion.findAll()
          .tap (arr) =>
            expect(arr.length).to.eq(2)
            newVersions = arr.filter((av) -> av.id != @existingArticleVersion.id)
            expect(newVersions.length).to.eq(1)
            expect(newVersions[0].urlVersionId).to.eq(@existingUrlVersion.id)
            expect(newVersions[0].articleId).not.to.eq(@existingArticle.id)

      it 'should add nothing to the urlJobQueue', ->
        reqPromise(url: 'http://example.org')
          .tap -> expect(global.urlJobQueue.queue).not.to.have.been.called

  describe '#destroy', ->
    req = (slug, id) ->
      supertest(app)
        .delete("/stories/#{slug}/articles/#{id}")
        .set('Accept', 'application/json')

    reqPromise = (slug, id) ->
      r = req(slug, id)
      Promise.promisify(r.end, r)()

    beforeEach ->
      @url1 = null
      @article1 = null

      Url.create({ url: 'http://example.org' }, 'user@example.org')
        .then((u) => @url1 = u)
        .then(=> Article.create({ storyId: @story1.id, urlId: @url1.id }, 'user@example.org'))
        .then((a) => @article1 = a)

    it 'should return 404 when the Story does not exist', ->
      reqPromise('some-slug', 'abcdef')
        .should.eventually.contain(status: 404)

    it 'should return 200 OK when the Article does not exist', ->
      reqPromise(@story1.slug, 'e76b2d33-2eb4-42cf-b50f-9453de057671')
        .should.eventually.contain(status: 200)

    it 'should return 200 OK when the Article exists', ->
      reqPromise(@story1.slug, @article1.id)
        .should.eventually.contain(status: 200)

    it 'should leave the Url in the database', ->
      reqPromise(@story1.slug, @article1.id)
        .then(=> Url.find(id: @url1.id))
        .should.eventually.exist

    it 'should delete the Article', ->
      reqPromise(@story1.slug, @article1.id)
        .then(=> Article.find(id: @article1.id))
        .should.eventually.not.exist
