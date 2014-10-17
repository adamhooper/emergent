UrlReparser = require('../lib/url_reparser')
Promise = require('bluebird')
models = require('../../data-store').models
_ = require('lodash')

describe 'url_reparser', ->
  expectCreate = (n, urlId, urlGet, urlVersion, transaction, ms=null) ->
    f = models.UrlVersion.create
    expect(f).to.have.been.called
    expect(f.args[n][0]).to.deep.eq
      millisecondsSincePreviousUrlGet: ms
      body: urlVersion.body
      byline: urlVersion.byline
      headline: urlVersion.headline
      parserVersion: urlVersion.parserVersion
      publishedAt: urlVersion.publishedAt
      sha1: urlVersion.sha1 # we have a test to ensure it calculates this
      source: urlVersion.source
      urlGetId: urlGet.id
      urlId: urlId
    expect(f.args[n][1]).to.be.null
    expect(f.args[n][2]).to.have.property('createdAt', urlGet.createdAt)
    expect(f.args[n][2]).to.have.property('transaction', transaction)

  beforeEach ->
    @sandbox = sinon.sandbox.create()

    @sandbox.stub(models.UrlGet, 'findAll').returns(Promise.resolve([]))
    @sandbox.stub(models.UrlVersion, 'findAll').returns(Promise.resolve([]))
    @sandbox.stub(models.UrlVersion, 'create').returns(Promise.resolve(id: '00000000-0000-0000-0000-000000000000'))
    @sandbox.stub(models.UrlVersion, 'update').returns(Promise.resolve(id: '00000000-0000-0000-0000-000000000000'))
    @sandbox.stub(models.Article, 'findAll').returns(Promise.resolve([]))
    @sandbox.stub(models.ArticleVersion, 'findAll').returns(Promise.resolve([]))
    @sandbox.stub(models.ArticleVersion, 'create').returns(Promise.resolve(id: '00000000-0000-0000-0000-000000000000'))
    @sandbox.stub(models.ArticleVersion, 'bulkUpdate').returns(Promise.resolve(id: '00000000-0000-0000-0000-000000000000'))

    @urlId = 'f5c681b9-4869-476f-a324-6bd78b8c7100'
    @url = 'http://example.org'

    @g1 =
      id: '44dc0d7a-4d03-4a00-9a61-caa78ceccfb6'
      urlId: @urlId
      createdAt: new Date(1000)
      statusCode: 200
      responseHeaders: '{}'
      body: 'body 1'

    @g2 =
      id: 'd71d049e-2a90-4227-8fe8-0ae5bd77432d'
      urlId: @urlId
      createdAt: new Date(2000)
      statusCode: 200
      responseHeaders: '{}'
      body: 'body 2'

    @v1 =
      source: 'source 1'
      headline: 'headline 1'
      byline: 'byline 1'
      publishedAt: new Date(1000)
      body: 'body 1'
      parserVersion: 2
      sha1: 'b62cd9a289f71398fe7a561065401e9b36c1a0c5'

    @v2 =
      source: 'source 2'
      headline: 'headline 2'
      byline: 'byline 2'
      publishedAt: new Date(2000)
      body: 'body 2'
      parserVersion: 2
      sha1: 'd6321b78e755731023bebbb2e86befea209442c4'

    @htmlParser =
      parse: sinon.stub()

    @transaction =
      commit: sinon.stub().returns(Promise.resolve('committed'))
      rollback: sinon.stub().returns(Promise.resolve('rolled back'))

    @sandbox.stub(models.sequelize, 'transaction').returns(Promise.resolve(@transaction))

    @subject = new UrlReparser
      htmlParser: @htmlParser
      log: (->)

  afterEach ->
    @sandbox.restore()

  describe 'starting with no UrlVersion', ->
    beforeEach ->
      models.UrlVersion.findAll.returns(Promise.resolve([]))

    it 'should start and commit a transaction', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      @htmlParser.parse.returns(@v1)

      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expect(models.sequelize.transaction).to.have.been.called
        expect(@transaction.commit).to.have.been.called
        done()

    it 'should rollback on parser error', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      @htmlParser.parse.throws(new Error('an error'))

      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.have.property('message', 'an error')
        expect(models.sequelize.transaction).to.have.been.called
        expect(@transaction.rollback).to.have.been.called
        done()

    it 'should create a UrlVersion and accompanying ArticleVersions', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      @htmlParser.parse.returns(@v1)
      models.UrlVersion.create.returns(Promise.resolve(id: 'dbd36bcd-4aec-460f-aba9-7a65ae736dfe'))
      models.Article.findAll.returns(Promise.resolve([ id: '4237707a-a1d8-4161-a078-c5043cfdfb9f' ]))

      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expectCreate(0, @urlId, @g1, @v1, @transaction)
        expect(models.Article.findAll).to.have.been.calledWith({ where: { urlId: @urlId } })
        expect(models.Article.findAll.args[0][1]).to.have.property('transaction', @transaction)
        expect(models.ArticleVersion.create).to.have.been.calledWith({
          articleId: '4237707a-a1d8-4161-a078-c5043cfdfb9f'
          urlVersionId: 'dbd36bcd-4aec-460f-aba9-7a65ae736dfe'
        }, null)
        expect(models.ArticleVersion.create.args[0][2]).to.have.property('transaction', @transaction)
        done()

    it 'should calculate the sha1 automatically', (done) ->
      # This test is a hack to plug a weakness in the test suite -- for brevity
      # we put the sha1 in @v1 and @v2 even though htmlParser won't return it.
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      v = _.extend({}, @v1)
      delete v.sha1
      @htmlParser.parse.returns(v)

      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expectCreate(0, @urlId, @g1, @v1, @transaction)
        done()

    it 'should create a second UrlVersion if the two are different', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1, @g2 ]))
      @htmlParser.parse.onCall(0).returns(@v1)
      @htmlParser.parse.onCall(1).returns(@v2)
      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expectCreate(0, @urlId, @g1, @v1, @transaction, null)
        expectCreate(1, @urlId, @g2, @v2, @transaction, 1000)
        done()

    it 'should not create a second UrlVersion when the two are identical', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1, @g2 ]))
      @htmlParser.parse.returns(@v1)
      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expect(models.UrlVersion.create).to.have.been.calledOnce
        done()

  describe 'starting with UrlVersions', ->
    it 'should add a UrlVersion before the first UrlVersion', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      models.UrlVersion.findAll.returns(Promise.resolve([ @v2 ]))
      @htmlParser.parse.returns(@v1)
      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expectCreate(0, @urlId, @g1, @v1, @transaction, null)
        done()

    it 'should add a UrlVersion after the last UrlVersion', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1, @g2 ]))
      models.UrlVersion.findAll.returns(Promise.resolve([ @v1 ]))
      @htmlParser.parse.onCall(0).returns(@v1)
      @htmlParser.parse.onCall(1).returns(@v2)
      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expect(models.UrlVersion.create).to.have.been.calledOnce
        expectCreate(0, @urlId, @g2, @v2, @transaction, 1000)
        done()

    it 'should skip a UrlVersion when it is unchanged', (done) ->
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      models.UrlVersion.findAll.returns(Promise.resolve([ @v1 ]))
      @htmlParser.parse.returns(@v1)
      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expect(models.UrlVersion.create).not.to.have.been.called
        done()

    it 'should update a UrlVersion when only the parser version has changed', (done) ->
      v1 = _.extend(@v1, urlGetId: @g1.id, parserVersion: 1)
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      models.UrlVersion.findAll.returns(Promise.resolve([ v1 ]))
      @htmlParser.parse.returns(@v1)
      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expect(models.UrlVersion.create).not.to.have.been.called
        expect(models.UrlVersion.update).to.have.been.calledWith(
          v1,
          { parserVersion: @v1.parserVersion },
          null
        )
        expect(models.UrlVersion.update.args[0][3]).to.have.property('transaction', @transaction)
        expect(models.ArticleVersion.bulkUpdate).not.to.have.been.called
        done()

    it 'should update a UrlVersion completely if the data has changed', (done) ->
      v1 = _.extend({}, @v1, id: '85196cf5-9b27-409c-9d2a-adcea6118e79', urlGetId: @g1.id, parserVersion: 1)
      v1plus = _.extend({}, v1, parserVersion: 2, body: 'new body')
      models.UrlGet.findAll.returns(Promise.resolve([ @g1 ]))
      models.UrlVersion.findAll.returns(Promise.resolve([ v1 ]))
      @htmlParser.parse.returns(v1plus)
      @subject.reparse @urlId, @url, (err) =>
        expect(err).to.be.null
        expect(models.UrlVersion.create).not.to.have.been.called
        expect(models.UrlVersion.update).to.have.been.calledWith(v1, v1plus, null, transaction: @transaction)
        expect(models.ArticleVersion.bulkUpdate).to.have.been.calledWith(
          { stance: null, headlineStance: null },
          { urlVersionId: '85196cf5-9b27-409c-9d2a-adcea6118e79' },
          null,
          transaction: @transaction
        )
        done()
