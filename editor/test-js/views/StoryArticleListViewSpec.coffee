Backbone = require('backbone')
StoryArticleListView = require('../../assets/js/views/StoryArticleListView')
StoryArticleListItemView = require('../../assets/js/views/StoryArticleListItemView')

describe 'views/StoryArticleListView', ->
  class MockArticle extends Backbone.Model
    defaults:
      url: ''

  class MockArticles extends Backbone.Collection
    model: MockArticle

  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @collection = new MockArticles()
    @view = new StoryArticleListView(collection: @collection)

  afterEach ->
    @view.destroy()
    @sandbox.restore()

  describe 'with only a placeholder', ->
    beforeEach ->
      @collection.push({})

    it 'should be a <ul>', -> expect(@view.$el).to.be('ul')

  describe 'with articles', ->
    beforeEach ->
      @collection.reset()
      @collection.push(id: 1, url: 'http://example.org/1')
      @collection.push(id: 2, url: 'http://example.org/2')
      @collection.push({})
      @view.render()

    it 'should render items', ->
      expect(@view.children.first()).to.be.an.instanceOf(StoryArticleListItemView)

    describe 'on click', ->
      beforeEach ->
        @view.on('focus', @focusSpy = sinon.spy())
        @view.$('li:eq(1) a').click()

      it 'should trigger a "focus" event with the model', ->
        expect(@focusSpy).to.have.been.calledWith(@collection.at(1))

      it 'should add the "focus" class to the view', ->
        expect(@view.$('li:eq(1)')).to.have.class('focus')

      it 'should remove the "focus" element from other views', ->
        @view.$('li:eq(0) a').click()
        expect(@view.$('li:eq(0)')).to.have.class('focus')
        expect(@view.$('li:eq(1)')).not.to.have.class('focus')

    describe 'when a sub-view submits a new URL', ->
      beforeEach ->
        @newModel = @collection.at(2)
        @newModel.set(url: 'http://example.org/3')
        @view.children.findByModel(@newModel).trigger('create', @newModel)

      it 'should add a new placeholder model', ->
        expect(@collection.length).to.eq(4)
        expect(@collection.at(3).isNew()).to.be.true
