StoryListItemView = require('../../assets/js/views/StoryListItemView')
Story = require('../../assets/js/models/Story')

describe 'views/StoryListItemView', ->
  beforeEach ->
    @model = new Story(slug: 'a-slug', headline: 'Headline', description: 'description')
    @view = new StoryListItemView(model: @model)
    @view.render()

  afterEach ->
    @view.destroy()

  it 'should be an li', -> expect(@view.$el).to.be('li')
  it 'should show the slug', -> expect(@view.$('.slug')).to.have.text('a-slug')
  it 'should show the headline', -> expect(@view.$('.headline')).to.have.text('Headline')
  it 'should show the description', -> expect(@view.$('.description')).to.have.text('description')

  it 'should trigger click from slug or headline', ->
    spy = sinon.spy()
    @view.on('click', spy)
    @view.$('.headline a').click()
    @view.$('.slug a').click()
    expect(spy).to.have.been.calledTwice

  describe 'with window.confirm spied', ->
    beforeEach ->
      @userAnswer = false # what we'll give window.confirm()
      @sandbox = sinon.sandbox.create()
      @sandbox.stub(window, 'confirm', => @userAnswer)

    afterEach ->
      @sandbox.restore()

    it 'should send no delete signal when confirm fails', ->
      @userAnswer = false
      @view.on('delete', cb = sinon.spy())
      @view.$('.delete').click()
      expect(cb).not.to.have.been.called

    it 'should send a delete signal when confirm succeeds', ->
      @userAnswer = true
      @view.on('delete', cb = sinon.spy())
      @view.$('.delete').click()
      expect(cb).to.have.been.called
