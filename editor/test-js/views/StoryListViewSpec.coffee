define [
  'views/StoryListView'
  'views/StoryListItemView'
  'views/StoryListNoItemView'
  'collections/Stories'
], (StoryListView, StoryListItemView, StoryListNoItemView, Stories) ->
  describe 'views/StoryListView', ->
    beforeEach ->
      @collection = new Stories()
      @view = new StoryListView
        collection: @collection

    afterEach ->
      @view.close()

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

      it 'should render using StoryView', ->
        expect(@view.children.first()).to.be.an.instanceOf(StoryListItemView)

      it 'should trigger delete when a sub-view does', ->
        cb = sinon.spy()
        @view.on('delete', cb)
        @view.children.first().trigger('delete')
        expect(cb).to.have.been.calledWith('slug-a')
