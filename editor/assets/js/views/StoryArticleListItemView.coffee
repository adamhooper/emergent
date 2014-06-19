define [ 'underscore', 'marionette' ], (_, Marionette) ->
  Templates =
    collapsed: _.template('''
      <a class="summary detail-hidden" href="#">
        ▸
        <span class="source"><%- source %></span>
        <span class="headline"><%- headline %></span>
        <span class="author"><%- author %></span>
        <span class="url"><%- url %></span>
      </a>
    ''')
    expanded: _.template('''
      <a class="summary detail-visible" href="#">
        ▾
        <span class="source"><%- source %></span>
        <span class="headline"><%- headline %></span>
        <span class="author"><%- author %></span>
        <span class="url"><%- url %></span>
      </a>
      <form method="post" action="#">
        <div class="form-group">
          <label for="new-article-url">URL</label>
          <input id="new-article-url" name="url" class="form-control" value="<%- url %>" placeholder="e.g. http://example.org/story.html">
        </div>
        <div class="form-group">
          <label for="new-article-truthiness">Truthiness</label>
          <div class="radio">
            <label>
              <input id="new-article-truthiness" type="radio" name="truthiness" value="" <%- truthiness == '' ? 'checked' : '' %>>
              I haven't looked
            </label>
          </div>
          <div class="radio">
            <label>
              <input type="radio" name="truthiness" value="myth" <%- truthiness == 'myth' ? 'checked' : '' %>>
              Myth
            </label>
          </div>
          <div class="radio">
            <label>
              <input type="radio" name="truthiness" value="truth" <%- truthiness == 'truth' ? 'checked' : '' %>>
              Truth
            </label>
          </div>
          <div class="radio">
            <label>
              <input type="radio" name="truthiness" value="claim" <%- truthiness == 'claim' ? 'checked' : '' %>>
              Claim
            </label>
          </div>
        </div>
        <fieldset class="article-automatic-fields">
          <legend>Truthmaker should fill these in automatically</legend>
          <div class="form-group">
            <label for="new-article-headline">Headline</label>
            <input id="new-article-headline" name="headline" class="form-control" placeholder="e.g. Man bites dog" value="<%- headline %>">
          </div>
          <div class="form-group">
            <label for="new-article-published-at">Published/updated date</label>
            <input type="datetime-local" id="new-article-published-at" name="publishedAt" class="form-control" value="<%- publishedAt %>">
            <small class="help-block">(in your timezone)</small>
          </div>
          <div class="form-group">
            <label for="new-article-author">Author (byline)</label>
            <input id="new-article-author" name="author" class="form-control" placeholder="e.g. Stephen Glass" value="<%- author %>">
          </div>
          <div class="form-group">
            <label for="new-article-source">Source (publication)</label>
            <input id="new-article-source" name="source" class="form-control" placeholder="e.g. The New York Times" value="<%- source %>">
          </div>
          <div class="form-group">
            <label for="new-article-body">Body text</label>
            <textarea id="new-article-body" name="body" class="form-control" rows="5" placeholder="e.g. Each paragraph was separated from its neighbors by two newlines."><%- body %></textarea>
          </div>
        </fieldset>
        <button type="submit" class="btn btn-primary">Save</button>
      </form>
    ''')

  class StoryArticleListItemCollapsedView extends Marionette.ItemView
    tagName: 'li'
    className: 'article article-collapsed'

    template: (serializedModel) ->
      f = if serializedModel['expanded?']
        Templates.expanded
      else
        Templates.collapsed
      f(serializedModel)

    ui:
      url: 'input[name=url]'
      source: 'input[name=source]'
      author: 'input[name=author]'
      headline: 'input[name=headline]'
      publishedAt: 'input[name=publishedAt]'
      body: 'textarea[name=body]'
      truthiness: 'input[name=truthiness]'

    events:
      'submit form': 'onSubmit'
      'click .detail-hidden': 'expand'
      'click .detail-visible': 'collapse'

    initialize: ->
      @expanded = false

    expand: (e) ->
      e?.preventDefault()
      @expanded = true
      @render()

    collapse: (e) ->
      e?.preventDefault()
      @expanded = false
      @render()

    serializeData: ->
      json = super()
      json['expanded?'] = @expanded
      json['publishedAt'] = @model.get('publishedAt') # and not what toJSON() gives
      json

    render: ->
      super()
      @el.className = if @expanded then 'article article-expanded' else 'article article-collapsed'
      this

    onSubmit: (e) ->
      e.preventDefault()
      @model.set({
        url: @ui.url.val()
        source: @ui.source.val()
        author: @ui.author.val()
        headline: @ui.headline.val()
        publishedAt: @ui.publishedAt.val()
        body: @ui.body.val()
        truthiness: @ui.truthiness.filter(':checked').val()
      }, userInput: true)
      false
