define [
  'backbone'
  'views/StoryArticleListItemView'
], (
  Backbone
  StoryArticleListItemView
) ->
  describe 'views/StoryArticleListItemView', ->
    class MockArticle extends Backbone.Model
      defaults:
        url: 'http://example.org'

      toJSON: ->
        json = super()
        json.publishedAt = new Date(json.publishedAt) + '-04:00'
        json

    beforeEach ->
      @model = new MockArticle()
      @view = new StoryArticleListItemView(model: @model)
      @view.render()

    afterEach ->
      @view.close()

    it 'should be a li', -> expect(@view.$el).to.be('li')
    it 'should render nothing but a elements', -> expect(@view.$el.children(':not(a)').length).to.equal(0)
