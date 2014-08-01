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

      describe 'on click', ->
        beforeEach ->
          @view.on('focus', @focusSpy = sinon.spy())
          @view.$('a:eq(1)').click()

        it 'should trigger a "focus" event with the model', ->
          expect(@focusSpy).to.have.been.calledWith(@collection.at(1))

        it 'should add the "focus" class to the view', ->
          expect(@view.$('li:eq(1)')).to.have.class('focus')

        it 'should remove the "focus" element from other views', ->
          @view.$('a:eq(0)').click()
          expect(@view.$('li:eq(0)')).to.have.class('focus')
          expect(@view.$('li:eq(1)')).not.to.have.class('focus')
