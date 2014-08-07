_ = require('lodash')
FetchHandler = require('../lib/fetch_handler')

models = require('../../data-store').models

describe 'FetchHandler', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create(useFakeTimers: true)

    @sandbox.stub(models.UrlVersion, 'find').returns(Promise.resolve(null))
    @sandbox.stub(models.UrlVersion, 'create')
    @sandbox.stub(models.Article, 'findAll').returns(Promise.resolve([]))
    @sandbox.stub(models.ArticleVersion, 'create').returns(Promise.resolve({}))

    @queue =
      queue: sinon.spy()

    @parsedObject =
      source: 'source'
      headline: 'headline'
      byline: 'byline'
      publishedAt: new Date(1)
      body: 'body'

    @parser =
      parse: sinon.stub().callsArgWith(2, null, @parsedObject)

    @fetchedObject =
      statusCode: 200
      body: '<html><body>body</body><html>'

    @fetcher =
      fetch: sinon.stub().callsArgWith(2, null, @fetchedObject)

    @handler = new FetchHandler
      queue: @queue
      htmlParser: @parser
      urlFetcher: @fetcher

  afterEach ->
    @sandbox.restore()

  describe 'fetching', ->
    beforeEach ->
      @id = '2764594f-bd77-49f0-9c73-31503eaede8f'
      @url = 'http://example.org'
      @go = (done) => @handler.handle(@id, @url, done)

    it 'should fetch the original URL', (done) ->
      @go =>
        expect(@fetcher.fetch).to.have.been.calledWith(@id, @url)
        done()

    it 'should call HtmlParser with the fetched URL', (done) ->
      @go =>
        expect(@parser.parse).to.have.been.calledWith(@url, @fetchedObject.body)
        done()

    it 'should not call HtmlParser when status is not 200', (done) ->
      @fetchedObject.statusCode = 404
      @go =>
        expect(@parser.parse).not.to.have.been.called
        done()

    it 'should queue another fetch', (done) ->
      @go =>
        expect(@queue.queue).to.have.been.calledWith('fetch', @id, @url, new Date(2 * 3600 * 1000))
        done()

    it 'should queue another fetch even when UrlFetcher fails', (done) ->
      @fetcher.fetch.callsArgWith(2, new Error("Fake fetch failure for #{@url}"))
      @go =>
        expect(@queue.queue).to.have.been.calledWith('fetch', @id, @url, new Date(2 * 3600 * 1000))
        done()

    it 'should queue another fetch even when HtmlParser fails', (done) ->
      @parser.parse.callsArgWith(2, new Error("Fake parse failure for #{@url}"))
      @go =>
        expect(@queue.queue).to.have.been.calledWith('fetch', @id, @url, new Date(2 * 3600 * 1000))
        done()

    describe 'when this UrlVersion already exists', ->
      beforeEach ->
        models.UrlVersion.find.returns(Promise.resolve(sha1: '1f28fcbf9c90691c5e847ef994ba6e6c05970452'))

      it 'should check the UrlVersion', (done) ->
        @go =>
          expect(models.UrlVersion.find).to.have.been.calledWith(where: { urlId: @id }, order: [[ 'createdAt', 'DESC' ]])
          done()

      it 'should not insert a new UrlVersion', (done) ->
        @go ->
          expect(models.UrlVersion.create).not.to.have.been.called
          done()

      it 'should not insert a new ArticleVersion', (done) ->
        @go ->
          expect(models.ArticleVersion.create).not.to.have.been.called
          done()

    describe 'when a different UrlVersion exists', ->
      beforeEach ->
        models.UrlVersion.find.returns(Promise.resolve(sha1: '1f28fcbf9c90691c5e847ef994ba6e6c05970453'))
        models.UrlVersion.create.returns(Promise.resolve(id: '42ffe765-3b77-4f15-be97-a7cb9e6bd98f'))

      it 'should insert a new UrlVersion', (done) ->
        @go =>
          obj = _.extend({ urlId: @id }, @parsedObject)
          expect(models.UrlVersion.create).to.have.been.calledWith(obj)
          done()

      it 'should insert a new ArticleVersion for each Article with this Url', (done) ->
        models.Article.findAll.returns(Promise.resolve([
          { id: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03a' }
          { id: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03b' }
        ]))
        @go =>
          expect(models.Article.findAll).to.have.been.calledWith(where: { urlId: @id })
          expect(models.ArticleVersion.create).to.have.been.calledWith
            urlVersionId: '42ffe765-3b77-4f15-be97-a7cb9e6bd98f'
            articleId: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03a'
          expect(models.ArticleVersion.create).to.have.been.calledWith
            urlVersionId: '42ffe765-3b77-4f15-be97-a7cb9e6bd98f'
            articleId: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03b'
          done()

    describe 'when there is no other UrlVersion', ->
      beforeEach ->
        models.UrlVersion.find.returns(Promise.resolve(null))

      it 'should insert a new UrlVersion', (done) ->
        @go ->
          expect(models.UrlVersion.create).to.have.been.called
          done()

    describe 'when a different UrlVersion exists', ->
      beforeEach ->
        models.UrlVersion.find.returns(Promise.resolve(sha1: '1f28fcbf9c90691c5e847ef994ba6e6c05970453'))
        models.UrlVersion.create.returns(Promise.resolve(id: '42ffe765-3b77-4f15-be97-a7cb9e6bd98f'))

      it 'should insert a new UrlVersion', (done) ->
        @go =>
          obj = _.extend({ urlId: @id }, @parsedObject)
          expect(models.UrlVersion.create).to.have.been.calledWith(obj)
          done()

      it 'should insert a new ArticleVersion for each Article with this Url', (done) ->
        models.Article.findAll.returns(Promise.resolve([
          { id: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03a' }
          { id: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03b' }
        ]))
        @go =>
          expect(models.Article.findAll).to.have.been.calledWith(where: { urlId: @id })
          expect(models.ArticleVersion.create).to.have.been.calledWith
            urlVersionId: '42ffe765-3b77-4f15-be97-a7cb9e6bd98f'
            articleId: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03a'
          expect(models.ArticleVersion.create).to.have.been.calledWith
            urlVersionId: '42ffe765-3b77-4f15-be97-a7cb9e6bd98f'
            articleId: 'ac89cbaf-ff6d-4f68-bd97-3d91661cc03b'
          done()
