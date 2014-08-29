HtmlParser = require('../../lib/parser/html_parser')

describe 'HtmlParser', ->
  beforeEach ->
    @simpleParseRetval =
      headline: ''
      byline: []
      body: []
      publishedAt: null

  it 'should invoke the correct SiteParser', (done) ->
    badSiteParser =
      testUrl: sinon.stub().returns(false)
      parse: sinon.stub().returns(@simpleParseRetval)
      version: 1

    goodSiteParser =
      testUrl: sinon.stub().returns(true)
      parse: sinon.stub().returns(@simpleParseRetval)
      version: 2

    subject = new HtmlParser()
    subject.addSiteParser(badSiteParser)
    subject.addSiteParser(goodSiteParser)

    subject.parse 'http://example.org', '<html></html>', (err) ->
      expect(err).to.be.null
      expect(badSiteParser.testUrl).to.have.been.called
      expect(badSiteParser.parse).not.to.have.been.called
      expect(goodSiteParser.testUrl).to.have.been.called
      expect(goodSiteParser.parse).to.have.been.called
      done()

  it 'should give an error when there is no valid SiteParser', (done) ->
    subject = new HtmlParser()
    subject.addSiteParser(testUrl: -> false)
    subject.parse 'http://example.org', '<html></html>', (err) ->
      expect(err).to.be.an.instanceOf(Error)
      done()

  describe 'when parsing with a good siteParser', ->
    beforeEach ->
      parseResult = {}
      for k, v of @simpleParseRetval
        parseResult[k] = v

      @siteParser =
        testUrl: -> true
        parse: sinon.stub().returns(parseResult)
        version: 123

      @subject = new HtmlParser()
      @subject.addSiteParser(@siteParser)

      @handleResultProperty = (prop, siteParserValue, expected, done) =>
        parseResult[prop] = siteParserValue
        @subject.parse 'http://example.org', '<html></html>', (err, val) ->
          expect(val[prop]).to.deep.eq(expected)
          done()

    it 'should call SiteParser.parse(url, $, h)', (done) ->
      stub = @siteParser.parse
      @subject.parse 'http://example.org', '<html><body><p>foo</p></body></html>', (err, val) ->
        expect(stub).to.have.been.called
        args = stub.lastCall.args
        expect(args[0]).to.deep.eq('http://example.org')
        # Test that $ is a Cheerio object.
        expect(args[1]('body').find('p').text()).to.eq('foo')
        # Test that h is a bunch of helpers.
        expect(args[2].texts).to.be.a.function
        done()

    it 'should return the source', (done) ->
      @handleResultProperty('source', 'foo', 'foo', done)

    it 'should return the headline', (done) ->
      @handleResultProperty('headline', 'foo', 'foo', done)

    it 'should return the body', (done) ->
      @handleResultProperty('body', [ 'para1', 'para2' ], "para1\n\npara2", done)

    it 'should return the byline', (done) ->
      @handleResultProperty('byline', [ 'Adam Hooper', 'Craig Silverman' ], 'Adam Hooper, Craig Silverman', done)

    it 'should return a null publishedAt as null', (done) ->
      @handleResultProperty('publishedAt', null, null, done)

    it 'should return a Moment publishedAt as a Date', (done) ->
      aMoment = require('moment')()
      @handleResultProperty('publishedAt', aMoment, aMoment.toDate(), done)

    it 'should return a Date publishedAt as a Date', (done) ->
      date = new Date()
      @handleResultProperty('publishedAt', date, date, done)

    it 'should return the version', (done) ->
      @subject.parse 'http://example.org', '<html></html>', (err, val) ->
        expect(val.version).to.eq(123)
        done()
