_ = require('lodash')

DefaultAttrs =
  slug: 'a-slug'
  headline: 'A Headline'
  description: 'A Description'
  origin: 'An Origin'
  originUrl: 'http://example.org'
  published: true
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
      .then (res) ->
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
        expect(claim.createdAt).to.eq(new Date(2000).toISOString())
        expect(claim).not.to.have.property('updatedAt')
        expect(claim).not.to.have.property('createdBy')
        expect(claim).not.to.have.property('updatedBy')

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

  it 'should hide unpublished claims', ->
    createClaim(slug: 'slug-2', published: false)
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
          models.UrlPopularityGet.create(urlId: url1.id, service: 'facebook', rawData: '', shares: 10)
          models.UrlPopularityGet.create(urlId: url1.id, service: 'facebook', rawData: '', shares: 20) # a higher count should make the lower one disappear
          models.UrlPopularityGet.create(urlId: url1.id, service: 'twitter', rawData: '', shares: 14)
        ])
      .then -> models.Url.create(url: 'http://example.org/2')
      .then (url2) =>
        Promise.all([
          models.Article.create({ storyId: claim2.id, urlId: url2.id }, 'user@example.org')
          models.UrlPopularityGet.create(urlId: url2.id, service: 'facebook', rawData: '', shares: 30) # should not affect claim1 count
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
