Url = models.Url
UrlVersion = models.UrlVersion

describe 'UnparsedUrlController', ->
  createUrlVersion = (urlId, user) ->
    UrlVersion.create({
      urlId: urlId
      source: 'source'
      body: 'body'
      publishedAt: new Date()
      byline: 'byline'
      headline: 'headline'
    }, user)

  req = (method, path) ->
    ret = supertest(app)[method](path)
      .set('Accept', 'application/json')
    Promise.promisify(ret.end, ret)()

  describe '#index', ->
    it 'should not list a Url that has a UrlVersion', ->
      Url.create({ url: 'http://example.org' }, 'user@example.org')
        .then((u) -> createUrlVersion(u.id, null))
        .then(-> req('get', '/unparsed-urls'))
        .tap (res) ->
          expect(res.status).to.eq(200)
          expect(res.body).to.deep.eq([])

    it 'should list a Url that only has a manually-entered UrlVersion', ->
      Url.create({ url: 'http://example.org' }, 'user@example.org')
        .then((u) -> createUrlVersion(u.id, 'user@example.org'))
        .then(-> req('get', '/unparsed-urls'))
        .tap (res) ->
          expect(res.status).to.eq(200)
          expect(res.body).to.deep.eq([ 'http://example.org' ])

    it 'should not list a Url that has both a manually-entered UrlVersion and an automatic one', ->
      Url.create({ url: 'http://example.org' }, 'user@example.org')
        .then (u) -> Promise.all([
          createUrlVersion(u.id, null)
          createUrlVersion(u.id, 'user@example.org')
        ])
        .then(-> req('get', '/unparsed-urls'))
        .tap (res) ->
          expect(res.status).to.eq(200)
          expect(res.body).to.deep.eq([])
