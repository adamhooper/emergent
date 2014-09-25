UrlsToReparseFinder = require('../lib/urls_to_reparse_finder')
Promise = require('bluebird')
models = require('../../data-store').models

describe 'urls_to_reparse_finder', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()

    @urlToCurrentVersion =
      'http://example.org/2': 2
      'http://exampel.org/3': 3

    @htmlParser =
      urlToSiteParser: (url) =>
        # Returns a SiteParser with version from @urlToCurrentVersion, or null
        v = @urlToCurrentVersion[url]
        v && { version: v} || null

    @subject = new UrlsToReparseFinder
      htmlParser: @htmlParser

    @sandbox.stub(models.sequelize, 'query').returns(Promise.resolve([]))

    @setUrlsFromDb = (ret) ->
      models.sequelize.query.returns(Promise.resolve(ret))

  afterEach ->
    @sandbox.restore()

  it 'should run a query', (done) ->
    @subject.findUrlsToReparse (err) ->
      expect(err).to.be.null
      expect(models.sequelize.query).to.have.been.called

      normalize = (s) -> s.trim().replace(/\s+/g, '')

      q = models.sequelize.query.args[0][0]
      expect(normalize(q)).to.eq(normalize('''
        SELECT u.id, u.url, MAX(uv."parserVersion") AS "lastParserVersion"
        FROM "Url" u 
        LEFT JOIN "UrlVersion" uv ON u.id = uv."urlId"
        GROUP BY u.id, u.url
      '''))
      done()

  it 'should call done with an empty Array when appropriate', (done) ->
    @subject.findUrlsToReparse (err, val) ->
      expect(err).to.be.null
      expect(val).to.deep.eq([])
      done()

  it 'should set currentParserVersion on returned items', (done) ->
    @setUrlsFromDb([
      { id: '123', url: 'http://example.org/2', lastParserVersion: 1 }
    ])
    @subject.findUrlsToReparse (err, val) ->
      expect(err).to.be.null
      expect(val).to.deep.eq([
        id: '123'
        url: 'http://example.org/2'
        lastParserVersion: 1
        currentParserVersion: 2
      ])
      done()

  it 'should filter out unparseable URLs', (done) ->
    @setUrlsFromDb([
      { id: '123', url: 'http://example.org/123', lastParserVersion: 123 }
    ])
    @subject.findUrlsToReparse (err, val) ->
      expect(err).to.be.null
      expect(val).to.deep.eq([])
      done()

  it 'should filter out URLs when the current parser is older than the previous one', (done) ->
    @setUrlsFromDb([
      { id: '123', url: 'http://example.org/2', lastParserVersion: 3 }
    ])
    @subject.findUrlsToReparse (err, val) ->
      expect(err).to.be.null
      expect(val).to.deep.eq([])
      done()

  it 'should filter out URLs when the current parser is the previous one', (done) ->
    @setUrlsFromDb([
      { id: '123', url: 'http://example.org/2', lastParserVersion: 2 }
    ])
    @subject.findUrlsToReparse (err, val) ->
      expect(err).to.be.null
      expect(val).to.deep.eq([])
      done()

  it 'should return URLs when the last parser did not exist', (done) ->
    @setUrlsFromDb([
      { id: '123', url: 'http://example.org/2', lastParserVersion: null }
    ])
    @subject.findUrlsToReparse (err, val) ->
      expect(err).to.be.null
      expect(val).to.deep.eq([
        id: '123'
        url: 'http://example.org/2'
        lastParserVersion: null
        currentParserVersion: 2
      ])
      done()
