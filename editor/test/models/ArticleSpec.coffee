describe 'Article', ->
  beforeEach ->
    # Start with a valid Article
    @article = new Article._model
      url: 'http://example.org/story'
      createdBy: 'adam@adamhooper.com'
      updatedBy: 'adam@adamhooper.com'

  it 'should require a URL', ->
    @article.url = undefined
    Q.npost(@article, 'validate')
      .should.eventually.be.rejected

  it 'should require the URL have a protocol', ->
    @article.url = 'www.example.org'
    Q.npost(@article, 'validate')
      .should.eventually.be.rejected

  it 'should allow a good URL', ->
    @article.url = 'http://example.org'
    Q.npost(@article, 'validate')
      .should.eventually.be.fulfilled
