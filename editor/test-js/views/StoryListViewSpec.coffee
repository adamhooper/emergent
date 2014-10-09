StoryListView = require('../../assets/js/views/StoryListView')
StoryListItemView = require('../../assets/js/views/StoryListItemView')
StoryListNoItemView = require('../../assets/js/views/StoryListNoItemView')
Stories = require('../../assets/js/collections/Stories')

describe 'views/StoryListView', ->
  beforeEach ->
    @collection = new Stories()
    @view = new StoryListView
      collection: @collection

  afterEach ->
    @view.destroy()

  it 'should be a <ul>', ->
    @view.render()
    expect(@view.$el).to.be('ul')

  describe 'with no stories', ->
    beforeEach -> @view.render()

    it 'should default to a StoryListNoItemView', ->
      expect(@view.children.first()).to.be.an.instanceOf(StoryListNoItemView)

  describe 'with stories', ->
    beforeEach ->
      @collection.push(slug: 'slug-a')
      @collection.push(slug: 'slug-b')
      @view.render()

    it 'should render using StoryView', ->
      expect(@view.children.first()).to.be.an.instanceOf(StoryListItemView)

    it 'should trigger delete when a sub-view does', ->
      spy = sinon.spy()
      @view.on('childview:delete', spy)
      @view.children.first().trigger('delete')
      expect(spy).to.have.been.called

    it 'should trigger click when a sub-view does', ->
      spy = sinon.spy()
      @view.on('childview:click', spy)
      @view.children.first().trigger('click')
      expect(spy).to.have.been.called
