Backbone = require('backbone')
StoryArticleListItemView = require('../../assets/js/views/StoryArticleListItemView')

describe 'views/StoryArticleListItemView', ->
  class MockArticle extends Backbone.Model
    defaults:
      url: 'http://example.org'

  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @model = new MockArticle()
    @view = new StoryArticleListItemView(model: @model)

  afterEach ->
    @view.destroy()
    @sandbox.restore()

  describe 'when model is empty', ->
    beforeEach -> @view.render()

    it 'should be a li', -> expect(@view.$el).to.be('li')
    it 'should contain a form', -> expect(@view.$('form')).to.exist

    it 'should do nothing when submitting an empty URL', ->
      @model.on('save', saveSpy = sinon.spy())
      @view.on('create', createSpy = sinon.spy())
      @view.$('input[name=url]').val('')
      @view.$('form').submit()
      expect(saveSpy).not.to.have.been.called
      expect(createSpy).not.to.have.been.called

    describe 'when submitting a URL', ->
      beforeEach ->
        @sandbox.stub(@model, 'save')
        @view.on('create', @createSpy = sinon.spy())
        @view.$('input[name=url]').val('http://example.org/1')
        @view.$('form').submit()

      it 'should trigger create', -> expect(@createSpy).to.have.been.calledWith(@model)
      it 'should call model.save', -> expect(@model.save).to.have.been.calledWith(url: 'http://example.org/1')

      it 'should disable the form fields', ->
        expect(@view.$('input')).to.have.prop('disabled', true)

      it 'should replace the button with a spinner', ->
        expect(@view.$('button')).not.to.exist
        expect(@view.$('.form-control-feedback .spin')).to.exist

      it 'should render as a normal URL on success', ->
        @model.set(id: '12345', url: 'http://example.org/1') # because Backbone will do this for us
        @model.save.lastCall.args[1].success(@model, id: '12345', url: 'http://example.org/1')
        expect(@view.$('form')).not.to.exist
        expect(@view.$('a')).to.contain('http://example.org/1')

      it 'should render an error on failure', ->
        @model.save.lastCall.args[1].error(@model, 'response')
        expect(@view.$('.form-control-feedback .error')).to.exist
        expect(@view.$el).to.have.class('has-error')

  describe 'when model is non-empty', ->
    beforeEach ->
      @model.set(id: 1, url: 'http://example.org/1')
      @view.render()

    it 'should just contain <a> and <button>s', ->
      els = @view.$el.children()
      expect(els.filter('a,button')).to.exist
      expect(els.filter(':not(a,button)')).not.to.exist

    it 'should contain the url', ->
      expect(@view.$el).to.contain('http://example.org/1')

    it 'should trigger click on click', ->
      @view.on('click', spy = sinon.spy())
      @view.$('a.select').click()
      expect(spy).to.have.been.calledWith(@model)

    it 'should delete on click', ->
      @sandbox.stub(window, 'confirm').returns(true)
      @model.destroy = sinon.spy()
      @view.$('button.delete').click()
      expect(@model.destroy).to.have.been.called

    it 'should not delete on click if not confirmed', ->
      @sandbox.stub(window, 'confirm').returns(false)
      @model.destroy = sinon.spy()
      @view.$('button.delete').click()
      expect(@model.destroy).not.to.have.been.called
