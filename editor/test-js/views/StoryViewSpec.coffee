define [
  'views/StoryView'
  'backbone'
], (StoryView, Backbone) ->
  describe 'views/StoryView', ->
    class MockStory extends Backbone.Model
      idAttribute: 'slug'

    beforeEach ->
      @model = new MockStory(slug: 'a-slug', headline: 'Headline', description: 'Description')
      @view = new StoryView(model: @model)
      @view.render()

    afterEach ->
      @view.close()

    it 'should show the slug', -> expect(@view.$('h3.slug')).to.have.text('a-slug')
    it 'should show the headline', -> expect(@view.$('.headline')).to.have.text('Headline')
    it 'should show the description', -> expect(@view.$('.description')).to.have.text('Description')
