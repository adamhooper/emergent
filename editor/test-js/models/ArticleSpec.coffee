define [ 'models/Article' ], (Article) ->
  describe 'models/Article', ->
    describe 'with a collection that has a url', ->
      beforeEach ->
        @collection =
          url: -> '/stories/a-slug/articles'
        @article = new Article(url: 'https://example.com')
        @article.collection = @collection

      it 'should have the url attribute', -> expect(@article.get('url')).to.equal('https://example.com')
      it 'should have the proper #create url', -> expect(@article.url()).to.equal('/stories/a-slug/articles')
      it 'should have the proper #show url', ->
        @article.set(id: '12345')
        expect(@article.url()).to.equal('/stories/a-slug/articles/12345')

    it 'should add timezone to publishedAt when serializing', ->
      article = new Article(publishedAt: '1985-04-12T23:20')
      expect(article.toJSON().publishedAt).to.match(/^1985-04-12T23:20(Z|[-+]\d\d:\d\d)$/)

    it 'should parse publishedAt and switch to local timezone when initializing', ->
      article = new Article({ publishedAt: '1985-04-12T23:20:50.520Z' }, parse: true)
      publishedAt = article.get('publishedAt')
      m = /^(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d)$/.exec(publishedAt) # no -0500, +0500, seconds, or Z
      expect(m).to.be.defined
      expect(new Date(m[1], m[2], m[3], m[4], m[5]).getTime()).to.eq(484788000000)
