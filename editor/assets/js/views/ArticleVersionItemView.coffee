define [
  'jquery'
  'marionette'
  'moment'
  'diff_match_patch'
], ($, Marionette, moment, diff_match_patch) ->
  textToHtml = (text) ->
    text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\n/g, '<br>')

  class ArticleVersionItemView extends Marionette.ItemView
    tagName: 'li'
    className: 'article-version'

    events:
      'click a.toggle-expand': 'onToggleExpand'
      'click a.toggle-edit-url-version': 'onToggleEditUrlVersion'
      'submit form': 'onSubmit'
      'click button.delete': 'onDelete'

    ui:
      urlVersion: 'fieldset.url-version'
      source: 'input[name=source]'
      headline: 'input[name=headline]'
      publishedAt: 'input[name=published-at]'
      byline: 'input[name=byline]'
      body: 'textarea[name=body]'
      stance: 'input[name=stance]'
      headlineStance: 'input[name=headline-stance]'
      comment: 'textarea[name=comment]'

    template: _.template('''
      <h3><a href="#" class="toggle-expand">
        <% if (isNew) { %>
          Insert a version manually
        <% } else { %>
          Fetched <time datetime="<%- createdAt %>"><%- createdAtString %></time>
        <% } %>
      </a></h3>
      <form method="post" action="#" class="<%- isNew ? 'create' : 'update' %>">
        <fieldset class="url-version <%- isNew ? 'editing' : '' %>">
          <legend>What the website says</legend>
          <div class="read-only">
            <article>
              <h4 class="headline"><%- urlVersion.headline %></h4>
              <p class="published">
                By <span class="byline"><%- urlVersion.byline %></span>;
                on <span class="source"><%- urlVersion.source %></span>
              </p>
              <div class="body"><%= urlVersion.bodyHtml %></div>
            </article>
            <a href="#" class="toggle-edit-url-version">Edit what the website says</a>
          </div>
          <div class="edit">
            <div class="form-group">
              <label for="version-<%- cid %>-source">Source (publication)</label>
              <input id="version-<%- cid %>-source" name="source" class="form-control" placeholder="e.g., The New York Times" value="<%- urlVersion.source %>" required>
            </div>
            <div class="form-group">
              <label for="version-<%- cid %>-headline">Headline</label>
              <input id="version-<%- cid %>-headline" name="headline" class="form-control" placeholder="e.g., Man Bites Dog" value="<%- urlVersion.headline %>" required>
            </div>
            <div class="form-group">
              <label for="version-<%- cid %>-published-at">Published/Updated date</label>
              <input type="datetime-local" id="version-<%- cid %>-published-at" name="published-at" class="form-control" value="<%- urlVersion.publishedAt %>" required>
              <small class="help-block">(in your timezone)</small>
            </div>
            <div class="form-group">
              <label for="version-<%- cid %>-byline">Byline</label>
              <input id="version-<%- cid %>-byline" name="byline" class="form-control" placeholder="e.g., Adam Hooper, Craig Silverman" value="<%- urlVersion.byline %>">
            </div>
            <div class="form-group">
              <label for="version-<%- cid %>-body">Body</label>
              <textarea id="version-<%- cid %>-body" name="body" class="form-control" rows="5" placeholder="e.g. Each paragraph was separated from its neighbors by two newlines." required><%- urlVersion.body %></textarea>
            </div>
          </div>
        </fieldset>
        <fieldset class="article-version">
          <legend>What Truthmaker editors say</legend>
          <div class="form-group">
            <label for="version-<%- cid %>-headline-stance">Does the headline support the claim?</label>
            <div class="radio"><label><input id="version-<%- cid %>-headline-stance" type="radio" name="headline-stance" value="" <%- headlineStance ? '' : 'checked' %>> I haven't looked</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="for" <%- headlineStance == 'for' ? 'checked' : '' %>> The headline is <em>for</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="against" <%- headlineStance == 'against' ? 'checked' : '' %>> The headline is <em>against</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="observing" <%- headlineStance == 'observing' ? 'checked' : '' %>> The headline is merely <em>reporting</em> the claim exists</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="ignoring" <%- headlineStance == 'ignoring' ? 'checked' : '' %>> The headline <em>does not mention</em> the claim</label></div>
          </div>
          <div class="form-group">
            <label for="version-<%- cid %>-stance">Does the body support the claim?</label>
            <div class="radio"><label><input id="version-<%- cid %>-stance" type="radio" name="stance" value="" <%- stance ? '' : 'checked' %>> I haven't looked</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="for" <%- stance == 'for' ? 'checked' : '' %>> The body is <em>for</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="against" <%- stance == 'against' ? 'checked' : '' %>> The body is <em>against</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="observing" <%- stance == 'observing' ? 'checked' : '' %>> The body is merely <em>reporting</em> the claim exists</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="ignoring" <%- stance == 'ignoring' ? 'checked' : '' %>> The body <em>does not mention</em> the claim</label></div>
          </div>
          <div class="form-group">
            <label for="version-<%- cid %>-comment">Comment</label>
            <textarea id="version-<%- cid %>-comment" name="comment" class="form-control" rows="2" placeholder="A note for other Truthmaker editors"><%- comment %></textarea>
          </div>
        </fieldset>
        <button type="submit" class="btn btn-default save"><%- isNew ? "Create version" : "Save changes" %></button>
        <% if (!isNew) { %>
          <button type="submit" class="btn delete">Delete this version</button>
        <% } %>
      </form>
    ''')

    render: ->
      super()

      @$el.toggleClass('complete', !!@model.get('stance') && !!@model.get('headlineStance'))

      @

    onToggleExpand: (e) ->
      e.preventDefault()
      @$el.toggleClass('expanded')

    onToggleEditUrlVersion: (e) ->
      e.preventDefault()
      @ui.urlVersion.toggleClass('editing')

    onSubmit: (e) ->
      e.preventDefault()
      isCreate = @model.isNew()

      @model.save @getDataFromForm(),
        success: =>
          @render() # isNew may change; form must reset
          if isCreate
            @model.collection.add({}) # new placeholder

    onDelete: (e) ->
      e.preventDefault()
      if window.confirm('Are you sure you want to delete this version? This cannot be undone.')
        @model.destroy()

    getBodyHtml: ->
      if @model.isNew()
        ''
      else
        index = @model.collection.indexOf(@model)
        curBody = @model.get('urlVersion').body

        if index == 0
          $('<div/>').text(curBody).html().replace(/\n/g, '<br/>')
        else
          prevBody = @model.collection.at(index - 1).get('urlVersion').body

          differ = new diff_match_patch()
          diff = differ.diff_main(prevBody, curBody)
          differ.diff_cleanupSemantic(diff)

          diff.map(([ op, text ]) ->
            escaped = textToHtml(text)
            switch op
              when -1 then "<del>#{escaped}</del>"
              when 1 then "<ins>#{escaped}</ins>"
              else escaped
          ).join('')

    serializeData: ->
      json = @model.toJSON()

      publishedAt = moment(json.urlVersion.publishedAt)

      isNew: @model.isNew()
      cid: @model.cid
      urlVersion:
        source: json.urlVersion.source
        headline: json.urlVersion.headline
        publishedAt: publishedAt.format('YYYY-MM-DDTHH:mm:ss')
        byline: json.urlVersion.byline
        body: json.urlVersion.body
        bodyHtml: @getBodyHtml()
      stance: json.stance ? ''
      headlineStance: json.headlineStance ? ''
      comment: json.comment
      createdAt: json.urlVersion.createdAt
      createdAtString: moment(json.urlVersion.createdAt).format('YYYY-MM-DD \\a\\t h:mm A')

    getDataFromForm: ->
      urlVersion:
        source: @ui.source.val().trim()
        headline: @ui.headline.val().trim()
        publishedAt: moment(@ui.publishedAt.val()).toDate()
        byline: @ui.byline.val().trim()
        body: @ui.body.val().trim()
      stance: @ui.stance.filter(':checked').val() || null
      headlineStance: @ui.headlineStance.filter(':checked').val() || null
      comment: @ui.comment.val().trim()
