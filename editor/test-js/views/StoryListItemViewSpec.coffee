define [
  'views/StoryListItemView'
  'models/Story'
], (StoryListItemView, Story) ->
  describe 'views/StoryListItemView', ->
    beforeEach ->
      @model = new Story(slug: 'a-slug', headline: 'Headline', description: 'description')
      @view = new StoryListItemView(model: @model)
      @view.render()

    afterEach ->
      @view.close()

    it 'should be an li', -> expect(@view.$el).to.be('li')
    it 'should show the slug', -> expect(@view.$('.slug')).to.have.text('a-slug')
    it 'should show the headline', -> expect(@view.$('.headline')).to.have.text('Headline')
    it 'should show the description', -> expect(@view.$('.description')).to.have.text('description')

    describe 'with window.confirm spied', ->
      beforeEach ->
        @userAnswer = false # what we'll give window.confirm()
        @sandbox = sinon.sandbox.create()
        @sandbox.stub(window, 'confirm', => @userAnswer)

      afterEach ->
        @sandbox.restore()

      it 'should send no delete signal when confirm fails', ->
        @userAnswer = false
        cb = sinon.spy()
        @view.on('delete', cb)
        @view.$('.delete').click()
        expect(cb).not.to.have.been.called

      it 'should send a delete signal when confirm succeeds', ->
        @userAnswer = true
        cb = sinon.spy()
        @view.on('delete', cb)
        @view.$('.delete').click()
        expect(cb).to.have.been.called
