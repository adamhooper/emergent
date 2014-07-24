define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class NewStoryArticleView extends Marionette.ItemView
    tagName: 'form'
    className: 'new-article'
    attributes:
      method: 'post'
      action: '#'

    template: _.template('''
      <legend>Add a new Article</legend>
      <div class="form-group">
        <input id="new-article-url" name="url" class="form-control" placeholder="http://example.org/story.html">
        <p class="help-block">Every time you see this story online, add the URL here.</p>
      </div>
      <button type="submit" class="btn btn-primary">Add Article</button>
    ''')

    events:
      'submit': 'onSubmit'

    onSubmit: (e) ->
      e.preventDefault()
      data = {}
      data[x.name] = x.value for x in @$el.serializeArray()
      @trigger('submit', data)
      @reset()

    reset: ->
      @el.reset()
