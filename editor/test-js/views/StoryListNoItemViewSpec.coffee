define [
  'views/StoryListNoItemView'
], (StoryListNoItemView) ->
  describe 'views/StoryListNoItemView', ->
    it 'should be an li', ->
      view = new StoryListNoItemView()
      expect(view.$el).to.be('li')
