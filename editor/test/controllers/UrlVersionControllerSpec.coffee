Promise = require('bluebird')

Url = global.models.Url
UrlVersion = global.models.UrlVersion

describe 'UrlVersionController', ->
  req = (method, path, body) ->
    ret = supertest(app)[method](path)
      .set('Accept', 'application/json')

    if body
      ret = ret.send(body)

    Promise.promisify(ret.end, ret)()

  beforeEach ->
    @url1 = null # One Url
    @url2 = null # A second Url
    @v11 = null  # Two UrlVersions on the first Url
    @v12 = null  # and no UrlVersions on Url2
    Url.create({ url: 'http://example1.org' }, 'user@example.org')
      .then (u) => @url1 = u
      .then -> Url.create({ url: 'http://example2.org' }, 'user@example.org')
      .then (u) => @url2 = u
      .then => UrlVersion.create({
        urlId: @url1.id
        source: 'source'
        headline: 'headline1'
        byline: 'byline1'
        publishedAt: new Date().toISOString()
        body: 'body1\n\nbody1\n\nbody1'
      }, 'user@example.org')
      .then (v) => @v11 = v
      .then => UrlVersion.create({
        urlId: @url1.id
        source: 'source'
        headline: 'headline2'
        byline: 'byline2'
        publishedAt: new Date().toISOString()
        body: 'body2\n\nbody2\n\nbody2'
      }, 'user@example.org')
      .then (v) => @v12 = v
      .catch(console.error)

  describe '#index', ->
    indexReq = (urlId) -> req('get', "/urls/#{urlId}/versions")

    it 'should return 404 when the Url does not exist', ->
      indexReq('ae5ac7d3-cc98-408a-83df-bf6b50774ada')
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return [] when there are no versions', ->
      indexReq(@url2.id)
        .tap (res) -> expect(res.status).to.eq(200)
        .tap (res) -> expect(res.body).to.deep.eq([])

    it 'should return versions when there are some', ->
      indexReq(@url1.id)
        .tap (res) => expect(x.id for x in res.body).to.deep.eq([ @v11.id, @v12.id ])

  describe '#create', ->
    createReq = (urlId, object) -> req('post', "/urls/#{urlId}/versions", object)

    candidateVersion =
      source: 'source'
      headline: 'headline3'
      byline: 'byline3'
      publishedAt: '2014-07-25T14:36:12.900Z'
      body: 'body3\n\nbody3\n\nbody3'

    it 'should return 404 when the url does not exist', ->
      createReq('ae5ac7d3-cc98-408a-83df-bf6b50774ada', candidateVersion)
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return the created object with fields added', ->
      createReq(@url2.id, candidateVersion)
        .tap (res) =>
          expect(res.status).to.eq(200)
          json = res.body

          for k, v of candidateVersion
            expect(json).to.have.property(k, v)

          expect(json).to.have.property('urlId', @url2.id)
          expect(json.sha1).to.be.a('String')
          expect(json.sha1).to.have.length(40)

  describe '#update', ->
    updateReq = (urlId, urlVersionId, attrs) -> req('put', "/urls/#{urlId}/versions/#{urlVersionId}", attrs)

    candidateVersion =
      source: 'source'
      headline: 'headline3'
      byline: 'byline3'
      publishedAt: '2014-07-25T14:36:12.900Z'
      body: 'body3\n\nbody3\n\nbody3'

    it 'should return 404 when the url does not exist', ->
      updateReq('ae5ac7d3-cc98-408a-83df-bf6b50774ada', @v11.id, candidateVersion)
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return 404 when the UrlVersion does not exist', ->
      updateReq(@url1.id, 'ae5ac7d3-cc98-408a-83df-bf6b50774ada', candidateVersion)
        .tap (res) -> expect(res.status).to.eq(404)

    it 'should return the updated object', ->
      updateReq(@url1.id, @v11.id, candidateVersion)
        .tap (res) =>
          expect(res.status).to.eq(200)
          json = res.body

          for k, v of candidateVersion
            expect(json).to.have.property(k, v)

          expect(json).to.have.property('urlId', @url1.id)
          expect(json.sha1).to.be.a('String')
          expect(json.sha1).to.have.length(40)

    it 'should set id, urlId and sha1 automatically, regardless of input', ->
      attrs = _.clone(candidateVersion)
      attrs.urlId = 'ae5ac7d3-cc98-408a-83df-bf6b50774ada'
      attrs.id = 'ae5ac7d3-cc98-408a-83df-bf6b50774ada'
      attrs.sha1 = '0700293f47ada0deddc9d863ca2fc26f5af89c10'
      updateReq(@url1.id, @v11.id, attrs)
        .tap (res) =>
          expect(res.status).to.eq(200)
          json = res.body

          expect(json).to.have.property('urlId', @url1.id)
          expect(json).to.have.property('id', @v11.id)
          expect(json.sha1).not.to.eq('0700293f47ada0deddc9d863ca2fc26f5af89c10')
