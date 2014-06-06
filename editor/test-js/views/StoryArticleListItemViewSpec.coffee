define [
  'backbone'
  'views/StoryArticleListItemView'
], (
  Backbone
  StoryArticleListItemView
) ->
  describe 'views/StoryArticleListItemView', ->
    DefaultAttributes =
      url: 'http://example.org'
      truthiness: 'myth'
      source: 'source'
      author: 'author'
      headline: 'headline'
      body: 'body'
      publishedAt: '1985-04-12T23:20'

    class MockArticle extends Backbone.Model
      defaults: DefaultAttributes

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
    it 'should render nothing but spans', -> expect(@view.$el.children(':not(span, a)').length).to.equal(0)
    it 'should have class article-collapsed', -> expect(@view.$el).to.have.class('article-collapsed')

    it 'should expand', ->
      @view.$('.summary').click()
      expect(@view.$el).to.have.class('article-expanded')

    describe 'when expanded', ->
      beforeEach -> @view.expand()

      it 'should have class article-expanded', -> expect(@view.$el).to.have.class('article-expanded')
      it 'should have a form', -> expect(@view.$('form').length).to.equal(1)

      it 'should fill in the form values', ->
        actual = {}
        actual[x.name] = x.value for x in @view.$('form').serializeArray()

        expected = DefaultAttributes
        expect(actual).to.deep.equal(expected)

      it 'should let the user edit the model and submit the changes on form submit', ->
        spy = sinon.spy()
        @model.on('change', spy)
        @view.$('input[name=url]').val('new url')
        @view.$('input[name=source]').val('new source')
        @view.$('input[name=headline]').val('new headline')
        @view.$('input[name=author]').val('new author')
        @view.$('textarea[name=body]').val('new body')
        @view.$('input[name=publishedAt]').val('1985-04-12T23:20')
        @view.$('input[name=truthiness][value=truth]').prop('checked', true)
        expect(spy).not.to.have.been.called
        @view.$('form').submit()
        expect(spy).to.have.been.calledWith(@model)

      it 'should collapse again', ->
        @view.$('.summary').click()
        expect(@view.$el.children(':not(span, a)').length).to.equal(0)
        expect(@view.$el).to.have.class('article-collapsed')
