HtmlParser = require('../../lib/parser/html_parser')

describe 'HtmlParser', ->
  beforeEach ->
    @simpleParseRetval =
      headline: ''
      byline: []
      body: []
      publishedAt: null

  it 'should invoke the correct SiteParser', ->
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

    subject.parse('http://example.org', '<html></html>')
    expect(badSiteParser.testUrl).to.have.been.called
    expect(badSiteParser.parse).not.to.have.been.called
    expect(goodSiteParser.testUrl).to.have.been.called
    expect(goodSiteParser.parse).to.have.been.called

  it 'should give an error when there is no valid SiteParser', ->
    subject = new HtmlParser()
    subject.addSiteParser(testUrl: -> false)
    expect(-> subject.parse('http://example.org', '<html></html>')).to.throw(Error)

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

      @handleResultProperty = (prop, siteParserValue, expected) =>
        parseResult[prop] = siteParserValue
        val = @subject.parse('http://example.org', '<html></html>')
        expect(val[prop]).to.deep.eq(expected)

    it 'should call SiteParser.parse(url, $, h)', ->
      stub = @siteParser.parse
      @subject.parse('http://example.org', '<html><body><p>foo</p></body></html>')
      expect(stub).to.have.been.called
      args = stub.lastCall.args
      expect(args[0]).to.deep.eq('http://example.org')
      # Test that $ is a Cheerio object.
      expect(args[1]('body').find('p').text()).to.eq('foo')
      # Test that h is a bunch of helpers.
      expect(args[2].texts).to.be.a.function

    it 'should return the source', -> @handleResultProperty('source', 'foo', 'foo')
    it 'should return the headline', -> @handleResultProperty('headline', 'foo', 'foo')
    it 'should return the body', -> @handleResultProperty('body', [ 'para1', 'para2' ], "para1\n\npara2")
    it 'should return the byline', -> @handleResultProperty('byline', [ 'Adam Hooper', 'Craig Silverman' ], 'Adam Hooper, Craig Silverman')
    it 'should return a null publishedAt as null', -> @handleResultProperty('publishedAt', null, null)

    it 'should return a Moment publishedAt as a Date', ->
      aMoment = require('moment')()
      @handleResultProperty('publishedAt', aMoment, aMoment.toDate())

    it 'should return a Date publishedAt as a Date', ->
      date = new Date()
      @handleResultProperty('publishedAt', date, date)

    it 'should return the version', ->
      val = @subject.parse('http://example.org', '<html></html>')
      expect(val.version).to.eq(123)
