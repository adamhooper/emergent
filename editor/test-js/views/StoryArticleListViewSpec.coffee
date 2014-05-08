define [
  'views/StoryArticleListView'
  'views/StoryArticleListItemView'
  'views/StoryArticleListNoItemView'
  'backbone'
], (
  StoryArticleListView,
  StoryArticleListItemView,
  StoryArticleListNoItemView,
  Backbone
) ->
  describe 'views/StoryArticleListView', ->
    class MockArticle extends Backbone.Model
      defaults:
        source: 'source'
        headline: 'headline'
        author: 'author'
        url: 'http://example.org'
        truthiness: ''

    class MockArticles extends Backbone.Collection
      model: MockArticle

    beforeEach ->
      @collection = new MockArticles()
      @view = new StoryArticleListView(collection: @collection)

    afterEach ->
      @view.close()

    describe 'with no stories', ->
      beforeEach -> @view.render()

      it 'should be a <ul>', -> expect(@view.$el).to.be('ul')
      it 'should show a no-item view', -> expect(@view.children.first()).to.be.an.instanceOf(StoryArticleListNoItemView)

    describe 'with articles', ->
      beforeEach ->
        @collection.push(url: 'http://example1.org')
        @collection.push(url: 'http://example2.org')

      it 'should render items', -> expect(@view.children.first()).to.be.an.instanceOf(StoryArticleListItemView)
      it 'should trigger delete from a sub-view, adding the CID', ->
        spy = sinon.spy()
        @view.on('delete', spy)
        @view.children.first().trigger('delete', 'foo')
        expect(spy).to.have.been.calledWith(@collection.at(0).cid, 'foo')
