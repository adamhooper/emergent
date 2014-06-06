define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class NewStoryArticleView extends Marionette.ItemView
    tagName: 'form'
    className: 'new-article'
    attributes:
      method: 'post'
      action: '#'

    template: _.template '''
      <legend>Add a new Article</legend>
      <p class="explanation">Every time you see this story online, add the URL and say whether the article got it right.</p>
      <div class="form-group">
        <label for="new-article-url">URL</label>
        <input id="new-article-url" name="url" class="form-control" placeholder="e.g. http://example.org/story.html">
      </div>
      <div class="form-group">
        <label for="new-article-truthiness">Truthiness</label>
        <div class="radio">
          <label>
            <input id="new-article-truthiness" type="radio" name="truthiness" value="" checked>
            I haven't looked
          </label>
        </div>
        <div class="radio">
          <label>
            <input type="radio" name="truthiness" value="myth">
            Myth
          </label>
        </div>
        <div class="radio">
          <label>
            <input type="radio" name="truthiness" value="truth">
            Truth
          </label>
        </div>
      </div>
      <fieldset class="article-automatic-fields">
        <legend>Truthmaker should fill these in automatically</legend>
        <div class="form-group">
          <label for="new-article-source">Source (publication)</label>
          <input id="new-article-source" name="source" class="form-control" placeholder="e.g. The New York Times">
        </div>
        <div class="form-group">
          <label for="new-article-author">Author (byline)</label>
          <input id="new-article-author" name="author" class="form-control" placeholder="e.g. Stephen Glass">
        </div>
        <div class="form-group">
          <label for="new-article-headline">Headline</label>
          <input id="new-article-headline" name="headline" class="form-control" placeholder="e.g. Man bites dog">
        </div>
        <div class="form-group">
          <label for="new-article-published-at">Published/updated date</label>
          <input type="datetime-local" id="new-article-published-at" name="publishedAt" class="form-control">
          <small class="help-block">(in your timezone)</small>
        </div>
        <div class="form-group">
          <label for="new-article-body">Body text</label>
          <textarea id="new-article-body" name="body" class="form-control" rows="5" placeholder="e.g. Each paragraph was separated from its neighbors by two newlines."></textarea>
        </div>
      </fieldset>
      <button type="submit" class="btn btn-primary">Create Article</button>
      '''

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
