SiteParser = require('../../lib/parser/site_parser')

describe 'SiteParser', ->
  describe 'default testUrl() implementation', ->
    beforeEach ->
      class TestUrlSiteParser extends SiteParser
        domains: [ 'example.org', 'www.example.org' ]
      @subject = new TestUrlSiteParser
      @do = (s) -> @subject.testUrl(s)

    it 'should return true for any domain in HTTP', ->
      expect(@do('http://example.org/page1.html')).to.be.true
      expect(@do('http://www.example.org/page1.html')).to.be.true

    it 'should return true for any domain in HTTPS', ->
      expect(@do('https://example.org/page1.html')).to.be.true
      expect(@do('https://www.example.org/page1.html')).to.be.true

    it 'should return true for the root page of a domain', ->
      expect(@do('http://example.org')).to.be.true

    it 'should return false for other domains', ->
      expect(@do('http://1example.org/page1.html')).to.be.false
      expect(@do('http://example.org1/page1.html')).to.be.false
      expect(@do('http://x.example.org/page1.html')).to.be.false
      expect(@do('http://example.org.x/page1.html')).to.be.false
      expect(@do('http://foo.com/example.org/page1.html')).to.be.false
      expect(@do('http://foo.com/http://example.org/page1.html')).to.be.false
      expect(@do('http://example.org.1')).to.be.false

  it 'should have an unimplemented parse() method', ->
    parser = new SiteParser()
    expect(-> parser.parse(null, null)).to.throw
