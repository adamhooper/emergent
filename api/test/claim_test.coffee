Promise = require('bluebird')
_ = require('lodash')

DefaultAttrs =
  slug: 'a-slug'
  headline: 'A Headline'
  description: 'A Description'
  origin: 'An Origin'
  originUrl: 'http://example.org'
  publishedAt: new Date(2500)
  truthiness: 'true'
  truthinessDescription: 'truthiness described'
  truthinessDate: new Date(1000)
  truthinessUrl: 'http://example2.org'
  createdAt: new Date(2000)
  createdBy: 'user@example.org'
  updatedAt: new Date(3000)
  updatedBy: 'user2@example.org'

createClaim = (attrs) ->
  attrs = _.extend({}, DefaultAttrs, attrs)
  models.Story.create(attrs, raw: true)

describe '/claims', ->
  beforeEach ->
    createClaim()
      .then((x) => @claim1 = x)
      .catch(console.warn)

  it 'should return the properties we want', ->
    api.get('/claims')
      .tap (res) ->
        body = res.body
        claims = body.claims
        expect(claims).to.have.length(1)
        claim = claims[0]
        expect(claim.slug).to.eq('a-slug')
        expect(claim.headline).to.eq('A Headline')
        expect(claim.description).to.eq('A Description')
        expect(claim.origin).to.eq('An Origin')
        expect(claim.originUrl).to.eq('http://example.org')
        expect(claim.truthiness).to.eq('true')
        expect(claim.truthinessDate).to.eq(new Date(1000).toISOString())
        expect(claim.truthinessDescription).to.eq('truthiness described')
        expect(claim.truthinessUrl).to.eq('http://example2.org')
        expect(claim.publishedAt).to.eq(new Date(2500).toISOString())
        expect(claim.createdAt).to.eq(new Date(2000).toISOString())
        expect(claim).not.to.have.property('updatedAt')
        expect(claim).not.to.have.property('createdBy')
        expect(claim).not.to.have.property('updatedBy')

  it 'should not return unpublished claims', ->
    createClaim(slug: 'x', publishedAt: null)
      .then -> api.get('/claims')
      .tap (res) ->
        expect(res.body.claims).to.have.length(1)

  it 'should not return published-in-the-future claims', ->
    createClaim(slug: 'x', publishedAt: new Date(new Date().getTime() + 100000))
      .then -> api.get('/claims')
      .tap (res) ->
        expect(res.body.claims).to.have.length(1)

  it 'should return published-extremely-recently claims', ->
    createClaim(slug: 'x', publishedAt: new Date())
      .then -> api.get('/claims')
      .tap (res) ->
        expect(res.body.claims).to.have.length(2)

  it 'should order claims by publishedAt', ->
    Promise.all([
      createClaim(slug: 'a', publishedAt: new Date(4000))
      createClaim(slug: 'b', publishedAt: new Date(6000))
      createClaim(slug: 'c', publishedAt: new Date(5000))
    ])
      .then -> api.get('/claims')
      .tap (res) ->
        expect(res.body.claims).to.have.length(4)
        expect(res.body.claims.map((x) -> x.slug)).to.deep.eq([ 'b', 'c', 'a', 'a-slug' ])

  it 'should return Categories as Arrays of Strings', ->
    Promise.all([
      createClaim(slug: 'b-slug', createdAt: new Date(10000))
      models.Category.create({ name: 'foo', slug: 'foo' }, 'test@example.org')
      models.Category.create({ name: 'bar', slug: 'bar' }, 'test@example.org')
      models.Category.create({ name: 'baz', slug: 'baz' }, 'test@example.org') # just here to confuse
    ])
      .spread (claim2, foo, bar, baz) =>
        models.CategoryStory.bulkCreate([
          { storyId: @claim1.id, categoryId: foo.id }
          { storyId: @claim1.id, categoryId: bar.id }
          { storyId: claim2.id, categoryId: bar.id }
        ], 'test@example.org')
      .then -> api.get('/claims')
      .tap (res) ->
        claims = res.body.claims
        expect(claims?[0]?.categories).to.deep.eq([ 'bar', 'foo' ])
        expect(claims?[1]?.categories).to.deep.eq([ 'bar' ])

  it 'should return Tags as Arrays of Strings', ->
    Promise.all([
      createClaim(slug: 'b-slug', createdAt: new Date(10000))
      models.Tag.create({ name: 'foo' }, 'test@example.org')
      models.Tag.create({ name: 'bar' }, 'test@example.org')
      models.Tag.create({ name: 'baz' }, 'test@example.org') # just here to confuse
    ])
      .spread (claim2, foo, bar, baz) =>
        models.StoryTag.bulkCreate([
          { storyId: @claim1.id, tagId: foo.id }
          { storyId: @claim1.id, tagId: bar.id }
          { storyId: claim2.id, tagId: bar.id }
        ], 'test@example.org')
      .then -> api.get('/claims')
      .tap (res) ->
        claims = res.body.claims
        expect(claims?[0]?.tags).to.deep.eq([ 'bar', 'foo' ])
        expect(claims?[1]?.tags).to.deep.eq([ 'bar' ])

  it 'should default to an empty nShares', ->
    api.get('/claims')
      .then((res) -> expect(res.body.claims[0]).to.have.property('nShares', 0))

  it 'should default to empty stances', ->
    api.get('/claims')
      .then((res) -> expect(res.body.claims[0].stances).to.deep.eq({}))

  it 'should count stances', ->
    Promise.all([
      models.Url.create(url: 'http://example.org/1')
      models.Url.create(url: 'http://example.org/2')
      models.Url.create(url: 'http://example.org/3')
    ])
      .spread (u1, u2, u3) => Promise.all([
        models.UrlVersion.create(urlId: u1.id, source: '', headline: '', body: '', byline: '')
        models.UrlVersion.create(urlId: u2.id, source: '', headline: '', body: '', byline: '')
        models.UrlVersion.create(urlId: u3.id, source: '', headline: '', body: '', byline: '')
        models.Article.create({ urlId: u1.id, storyId: @claim1.id }, 'user@example.org')
        models.Article.create({ urlId: u2.id, storyId: @claim1.id }, 'user@example.org')
        models.Article.create({ urlId: u3.id, storyId: @claim1.id }, 'user@example.org')
      ])
      .spread (uv1, uv2, uv3, a1, a2, a3) -> Promise.all([
        models.ArticleVersion.create(urlVersionId: uv1.id, articleId: a1.id, stance: 'for')
        models.ArticleVersion.create(urlVersionId: uv2.id, articleId: a2.id, stance: 'for')
        models.ArticleVersion.create(urlVersionId: uv3.id, articleId: a3.id, stance: 'against')
      ])
      .then(-> api.get('/claims'))
      .tap (res) ->
        claims = res.body.claims
        expect(claims[0].stances).to.deep.eq(for: 2, against: 1)

  it 'should not count stances from past ArticleVersions', ->
    models.Url.create(url: 'http://example.org/1')
      .then (u) => Promise.all([
        models.UrlVersion.create(urlId: u.id, source: '', headline: '', body: '', byline: '')
        models.UrlVersion.create(urlId: u.id, source: '', headline: '', body: '', byline: '')
        models.Article.create({ urlId: u.id, storyId: @claim1.id }, 'user@example.org')
      ])
      .spread (uv1, uv2, a) ->
        # Ensure version 2 comes later than version 1, so they can be sorted
        models.ArticleVersion.create(urlVersionId: uv1.id, articleId: a.id, stance: 'for')
          .delay(1) # Postgres stores times with millisecond precision
          .then(-> models.ArticleVersion.create(urlVersionId: uv2.id, articleId: a.id, stance: 'against'))
      .then(-> api.get('/claims'))
      .tap (res) ->
        claims = res.body.claims
        expect(claims[0].stances).to.deep.eq(against: 1)

  it 'should count null stances', ->
    models.Url.create(url: 'http://example.org/1')
      .then (u) => Promise.all([
        models.UrlVersion.create(urlId: u.id, source: '', headline: '', body: '', byline: '')
        models.Article.create({ urlId: u.id, storyId: @claim1.id }, 'user@example.org')
      ])
      .spread (uv, a) ->
        models.ArticleVersion.create(urlVersionId: uv.id, articleId: a.id, stance: null)
      .then(-> api.get('/claims'))
      .tap (res) ->
        claims = res.body.claims
        expect(claims[0].stances).to.deep.eq(null: 1)

  it 'should hide unpublished claims', ->
    createClaim(slug: 'slug-2', publishedAt: null)
      .then -> api.get('/claims')
      .then (res) ->
        expect(res.body.claims).to.have.length(1)

  it 'should sum up nShares', ->
    claim2 = null

    createClaim(slug: 'slug-2')
      .then((x) -> claim2 = x)
      .then -> models.Url.create(url: 'http://example.org/1')
      .then (url1) =>
        Promise.all([
          models.Article.create({ storyId: @claim1.id, urlId: url1.id }, 'user@example.org')
          models.UrlPopularityGet.create(urlId: url1.id, service: 'facebook', shares: 10)
          models.UrlPopularityGet.create(urlId: url1.id, service: 'facebook', shares: 20) # a higher count should make the lower one disappear
          models.UrlPopularityGet.create(urlId: url1.id, service: 'twitter', shares: 14)
        ])
      .then -> models.Url.create(url: 'http://example.org/2')
      .then (url2) =>
        Promise.all([
          models.Article.create({ storyId: claim2.id, urlId: url2.id }, 'user@example.org')
          models.UrlPopularityGet.create(urlId: url2.id, service: 'facebook', shares: 30) # should not affect claim1 count
        ])
      .then -> api.get('/claims')
      .then (res) =>
        claims = res.body.claims
        for claim in claims
          if claim.id == @claim1.id
            expect(claim).to.have.property('nShares', 34)
          else
            expect(claim).to.have.property('nShares', 30)

describe '/claims/:id', ->
  beforeEach ->
    createClaim()
      .then((x) => @claim1 = x)
      .catch(console.warn)

  it 'should return the properties we want', ->
    api.get("/claims/#{@claim1.id}")
      .then (res) ->
        claim = res.body
        expect(claim.slug).to.eq('a-slug')
        expect(claim.headline).to.eq('A Headline')
        expect(claim.description).to.eq('A Description')
        expect(claim.origin).to.eq('An Origin')
        expect(claim.originUrl).to.eq('http://example.org')
        expect(claim.truthiness).to.eq('true')
        expect(claim.truthinessDate).to.eq(new Date(1000).toISOString())
        expect(claim.truthinessDescription).to.eq('truthiness described')
        expect(claim.truthinessUrl).to.eq('http://example2.org')
        expect(claim.createdAt).to.eq(new Date(2000).toISOString())
        expect(claim).not.to.have.property('updatedAt')
        expect(claim).not.to.have.property('createdBy')
        expect(claim).not.to.have.property('updatedBy')

  it 'should return 404 on wrong id', ->
    api.get('/claims/cbea7bd7-7432-4923-98fc-0a9480830182')
      .then (res) ->
        expect(res.status).to.eq(404)
        expect(res.body).to.have.property('message', 'Claim not found')

describe 'POST /claims', ->
  # Spec: https://github.com/craigsilverman/emergent/wiki/User-submitted-claims
  beforeEach ->
    models.Url.create(url: 'http://example.org/foo')
      .tap((u) => @url = u)

  it 'should not create a new Url', ->
    api.post('/claims', claim: 'foo', url: 'http://example.org/bar')
      .then(-> models.Url.findAll())
      .tap((urls) -> expect(urls.length).to.eq(1))

  it 'should create a UserSubmittedClaim', ->
    api.post('/claims', claim: 'foo', url: 'http://example.org/bar')
      .then(-> models.UserSubmittedClaim.findAll())
      .then((x) -> x[0])
      .tap (usc) ->
        expect(usc.id).to.exist
        expect(usc.requestIp).to.eq('127.0.0.1')
        expect(usc.claim).to.eq('foo')
        expect(usc.url).to.eq('http://example.org/bar')
        expect(usc.urlId).to.be.null
        expect(usc.spam).to.be.false
        expect(usc.archived).to.be.false

  it 'should link an existing Url', ->
    api.post('/claims', claim: 'foo', url: 'http://example.org/foo')
      .then(-> models.UserSubmittedClaim.findAll())
      .then((x) -> x[0])
      .tap((usc) => expect(usc.urlId).to.eq(@url.id))

  it 'should return Created', ->
    api.post('/claims', claim: 'foo', url: 'http://example.org/bar')
      .tap((res) -> expect(res.status).to.eq(201))

  it 'should disallow an empty claim', ->
    api.post('/claims', claim: '        ', url: 'http://example.org/bar')
      .tap((res) -> expect(res.status).to.eq(400))

  it 'should disallow an invalid url', ->
    api.post('/claims', claim: 'foo', url: 'http:/example.org/bar')
      .tap((res) -> expect(res.status).to.eq(400))
