Promise = require('bluebird')

Story = global.models.Story
Article = global.models.Article
ArticleVersion = global.models.ArticleVersion
Url = global.models.Url
UrlVersion = global.models.UrlVersion

describe 'ArticleVersionController', ->
  req = (method, path, body) ->
    ret = supertest(app)[method](path)
      .set('Accept', 'application/json')

    if body
      ret = ret.send(body)

    Promise.promisify(ret.end, ret)()

  beforeEach ->
    @email = 'user@example.org'
    @url = null
    @urlVersion = null  # with an ArticleVersion
    @article = null
    @articleVersion = null
    @story = null
    Url.create({ url: 'http://example1.org' }, @email).then((x) => @url = x)
      .then(=> Story.create({ slug: 'slug', headline: 'headline', description: 'description' }, @email)).then((x) => @story = x)
      .then(=> Article.create({ storyId: @story.id, urlId: @url.id }, @email)).then((x) => @article = x)
      .then(=> UrlVersion.create({
        urlId: @url.id
        source: 'source'
        headline: 'headline1'
        byline: 'byline1'
        publishedAt: new Date().toISOString()
        body: 'body1\n\nbody1\n\nbody1'
      }, @email)).then((x) => @urlVersion = x)
      .then(=> ArticleVersion.create({
        urlVersionId: @urlVersion.id
        articleId: @article.id
        truthiness: null
        headlineTruthiness: null
        comment: ''
      }, @email)).then((x) => @articleVersion = x)
      .catch(console.error)

  describe '#index', ->
    indexReq = (articleId) -> req('get', "/articles/#{articleId}/versions")

    it 'should return 404 when the Article does not exist', ->
      indexReq('ae5ac7d3-cc98-408a-83df-bf6b50774ada')
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return [] when there are no ArticleVersions', ->
      ArticleVersion.destroy()
        .then => indexReq(@article.id)
        .tap (res) ->
          expect(res.status).to.eq(200)
          expect(res.body).to.deep.eq([])

    it 'should return ArticleVersions with UrlVersions included', ->
      indexReq(@article.id)
        .tap (res) =>
          expect(res.status).to.eq(200)
          json = res.body
          expect(json.length).to.eq(1)
          expect(json).to.have.deep.property('[0].id', @articleVersion.id)
          expect(json[0].urlVersionId).to.eq(@urlVersion.id)
          expect(json[0].urlVersion).to.exist
          expect(json[0].urlVersion).to.have.property('id', @urlVersion.id)
          expect(json[0].urlVersion).to.have.property('publishedAt', @urlVersion.publishedAt.toISOString())
          expect(json[0].urlVersion).to.have.property('body', @urlVersion.body)
          expect(json[0].truthiness).to.be.null
          expect(json[0].headlineTruthiness).to.be.null
          expect(json[0].comment).to.eq('')

  describe '#create', ->
    createReq = (articleId, object) -> req('post', "/articles/#{articleId}/versions", object)

    candidateVersion =
      truthiness: 'truth'
      headlineTruthiness: 'claim'
      comment: 'comment'
      urlVersion:
        source: 'source'
        headline: 'headline2'
        byline: 'byline2'
        publishedAt: '2014-07-25T14:36:12.900Z'
        body: 'body2\n\nbody2\n\nbody2'

    it 'should return 404 when the Article does not exist', ->
      createReq('ae5ac7d3-cc98-408a-83df-bf6b50774ada', candidateVersion)
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return the created object with fields added', ->
      createReq(@article.id, candidateVersion)
        .tap (res) =>
          expect(res.status).to.eq(200)
          json = res.body

          t = (prop, value) -> expect(json).to.have.deep.property(prop, value)
          t('urlVersion.urlId', @url.id)
          t('urlVersion.id', json.urlVersionId)
          t('truthiness', 'truth')
          t('comment', 'comment')
          for k, v of candidateVersion.urlVersion
            t("urlVersion.#{k}", v)
          expect(json.urlVersion.sha1).to.be.a('String')
          expect(json.urlVersion.sha1).to.have.length(40)

  describe '#update', ->
    updateReq = (articleId, versionId, attrs) -> req('put', "/articles/#{articleId}/versions/#{versionId}", attrs)

    candidateVersion =
      truthiness: 'truth'
      headlineTruthiness: 'claim'
      comment: 'comment'
      urlVersion:
        source: 'source'
        headline: 'headline2'
        byline: 'byline2'
        publishedAt: '2014-07-25T14:36:12.900Z'
        body: 'body2\n\nbody2\n\nbody2'

    it 'should return 404 when the Article does not exist', ->
      updateReq('ae5ac7d3-cc98-408a-83df-bf6b50774ada', @articleVersion.id, candidateVersion)
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return 404 when the ArticleVersion does not exist', ->
      updateReq(@article.id, 'ae5ac7d3-cc98-408a-83df-bf6b50774ada', candidateVersion)
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return the updated object', ->
      updateReq(@article.id, @articleVersion.id, candidateVersion)
        .tap (res) =>
          expect(res.status).to.eq(200)
          json = res.body

          t = (prop, value) -> expect(json).to.have.deep.property(prop, value)
          t('urlVersion.urlId', @url.id)
          t('urlVersion.id', json.urlVersionId)
          t('truthiness', 'truth')
          t('headlineTruthiness', 'claim')
          t('comment', 'comment')
          for k, v of candidateVersion.urlVersion
            t("urlVersion.#{k}", v)
          expect(json.urlVersion.sha1).to.be.a('String')
          expect(json.urlVersion.sha1).to.have.length(40)
