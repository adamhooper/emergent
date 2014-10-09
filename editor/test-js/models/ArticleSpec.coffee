Article = require('../../assets/js/models/Article')

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
