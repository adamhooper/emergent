_ = require('lodash')
$ = require('jquery')
Marionette = require('backbone.marionette')
moment = require('moment')
diff_match_patch = require('diff_match_patch').diff_match_patch

textToHtml = (text) ->
  text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>')

diffHtml = (text1, text2) ->
  differ = new diff_match_patch()
  diff = differ.diff_main(text1, text2)
  differ.diff_cleanupSemantic(diff)

  diff.map(([ op, text ]) ->
    escaped = textToHtml(text)
    switch op
      when -1 then "<del>#{escaped}</del>"
      when 1 then "<ins>#{escaped}</ins>"
      else escaped
  ).join('')

countDiffEdits = (text1, text2) ->
  differ = new diff_match_patch()
  diff = differ.diff_main(text1, text2)

  diff.reduce((total, [ op, text ]) ->
    switch op
      when 0 then total
      else total + text.length
  , 0)

module.exports = class ArticleVersionItemView extends Marionette.ItemView
  tagName: 'li'
  className: 'article-version'

  events:
    'click a.toggle-expand': 'onToggleExpand'
    'click a.toggle-edit-url-version': 'onToggleEditUrlVersion'
    'submit form': 'onSubmit'
    'click button.mark-unchanged': 'onMarkUnchanged'
    'click button.delete': 'onDelete'

  ui:
    urlVersion: 'fieldset.url-version'
    source: 'input[name=source]'
    headline: 'input[name=headline]'
    byline: 'input[name=byline]'
    body: 'textarea[name=body]'
    stance: 'input[name=stance]'
    headlineStance: 'input[name=headline-stance]'
    comment: 'textarea[name=comment]'

  template: _.template('''
    <% if (isNew) { %>
      <h3 class="version-new"><a href="#" class="toggle-expand">Insert a version manually</a></h3>
    <% } else { %>
      <h3 class="version-existing">
        <a href="#" class="toggle-expand">
          <span class="version-created-at"><%- createdBy ? 'Manually added' : 'Fetched' %> <time datetime="<%- createdAt %>"><%- createdAtString %></time></span>
          <i class="version-stance version-headline-stance-<%- headlineStance %>" title="Headline stance: <%- headlineStance %>"/>
          <i class="version-stance version-stance-<%- stance %>" title="Body stance: <%- stance %>"/>
        </a>
      </h3>
    <% } %>
    <form method="post" action="#" class="<%- isNew ? 'create' : 'update' %>">
      <% if (index > 0 && !isNew) { %>
        <fieldset class="diff">
          <legend>Quick Diff</legend>
          <div class="row">
            <div class="col-sm-8">
              <%= diffHtml %>
            </div>
            <div class="form-group col-sm-4">
              <button type="submit" class="form-control btn btn-default mark-unchanged">Ceci n'est pas une change</button>
              <p class="help-block">If the article has barely changed, click this to copy the previous version's stances and move on.</p>
            </div>
          </div>
        </fieldset>
      <% } %>
      <fieldset class="article-version">
        <legend>What Truthmaker editors say</legend>
        <div class="row">
          <div class="form-group col-sm-6">
            <label for="version-<%- cid %>-headline-stance">Does the headline support the claim?</label>
            <div class="radio"><label><input id="version-<%- cid %>-headline-stance" type="radio" name="headline-stance" value="" <%- headlineStance ? '' : 'checked' %>> I haven't looked</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="for" <%- headlineStance == 'for' ? 'checked' : '' %>> The headline is <em>for</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="against" <%- headlineStance == 'against' ? 'checked' : '' %>> The headline is <em>against</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="observing" <%- headlineStance == 'observing' ? 'checked' : '' %>> The headline is merely <em>reporting</em> the claim exists</label></div>
            <div class="radio"><label><input type="radio" name="headline-stance" value="ignoring" <%- headlineStance == 'ignoring' ? 'checked' : '' %>> The headline <em>does not mention</em> the claim</label></div>
          </div>
          <div class="form-group col-sm-6">
            <label for="version-<%- cid %>-stance">Does the body support the claim?</label>
            <div class="radio"><label><input id="version-<%- cid %>-stance" type="radio" name="stance" value="" <%- stance ? '' : 'checked' %>> I haven't looked</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="for" <%- stance == 'for' ? 'checked' : '' %>> The body is <em>for</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="against" <%- stance == 'against' ? 'checked' : '' %>> The body is <em>against</em> the claim</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="observing" <%- stance == 'observing' ? 'checked' : '' %>> The body is merely <em>reporting</em> the claim exists</label></div>
            <div class="radio"><label><input type="radio" name="stance" value="ignoring" <%- stance == 'ignoring' ? 'checked' : '' %>> The body <em>does not mention</em> the claim</label></div>
          </div>
        </div>
        <div class="row">
          <div class="form-group col-sm-8">
            <label for="version-<%- cid %>-comment">Comment</label>
            <textarea id="version-<%- cid %>-comment" name="comment" class="form-control" rows="2" placeholder="A note for other Truthmaker editors"><%- comment %></textarea>
          </div>
          <div class="form-group col-sm-4">
            <label>Actions</label>
            <button type="submit" class="form-control btn btn-primary save"><%- isNew ? "Create version" : "Save changes" %></button>
          </div>
        </div>
      </fieldset>
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
          <% if (createdBy !== null) { %>
            <a href="#" class="toggle-edit-url-version">Edit what the website says</a>
          <% } %>
        </div>
        <% if (!isNew && createdBy !== null) { %>
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
              <label for="version-<%- cid %>-byline">Byline</label>
              <input id="version-<%- cid %>-byline" name="byline" class="form-control" placeholder="e.g., Adam Hooper, Craig Silverman" value="<%- urlVersion.byline %>">
            </div>
            <div class="form-group">
              <label for="version-<%- cid %>-body">Body</label>
              <textarea id="version-<%- cid %>-body" name="body" class="form-control" rows="5" placeholder="e.g. Each paragraph was separated from its neighbors by two newlines." required><%- urlVersion.body %></textarea>
            </div>
          </div>
        <% } %>
      </fieldset>
      <% if (isNew || createdBy !== null) { %>
        <button type="submit" class="btn btn-primary save"><%- isNew ? "Create version" : "Save changes" %></button>
      <% } %>
      <% if (!isNew && createdBy !== null) { %>
        <button type="submit" class="btn btn-danger delete">Delete this version</button>
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
        @$el.removeClass('expanded')
        @render() # isNew may change; form must reset
        if isCreate
          @model.collection.add({}) # new placeholder

  onMarkUnchanged: (e) ->
    e.preventDefault()

    index = @model.collection.indexOf(@model)
    prevModel = @model.collection.at(index - 1)

    data = @getDataFromForm()
    data.stance = prevModel.get('stance')
    data.headlineStance = prevModel.get('headlineStance')
    delete data.urlVersion

    @model.save data,
      success: =>
        @$el.removeClass('expanded')
        @render() # reset form for stance changes

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

        diffHtml(prevBody, curBody)

  getDiffHtml: ->
    index = @model.collection.indexOf(@model)

    return null if index == 0 || @model.isNew()

    curVersion = @model.get('urlVersion')
    prevVersion = @model.collection.at(index - 1).get('urlVersion')

    return 'This version is byte-for-byte identical to the previous one.' if curVersion.sha1 == prevVersion.sha1

    keys = [
      { name: 'Source', key: 'source' }
      { name: 'Headline', key: 'headline' }
      { name: 'Byline', key: 'byline' }
    ]

    $dl = $('<dl/>')

    add = (heading, html) ->
      $dl.append($('<dt/>').text(heading))
      $dl.append($('<dd/>').html(html))

    for k in keys
      cur = curVersion[k.key] || ''
      prev = prevVersion[k.key] || ''

      if cur != prev
        add(k.name, diffHtml(prev, cur))

    curLede = curVersion.body.split(/\n/)[0]
    prevLede = prevVersion.body.split(/\n/)[0]
    if curLede != prevLede
      add('Lede', diffHtml(prevLede, curLede))

    editDistance = countDiffEdits(prevVersion.body, curVersion.body)
    if editDistance > 0
      add('Body characters inserted or removed', editDistance)

    $('<div/>').append($dl).html()

  serializeData: ->
    json = @model.toJSON()

    isNew: @model.isNew()
    index: @model.collection.indexOf(@model)
    cid: @model.cid
    diffHtml: @getDiffHtml()
    urlVersion:
      source: json.urlVersion.source
      headline: json.urlVersion.headline
      byline: json.urlVersion.byline
      body: json.urlVersion.body
      bodyHtml: @getBodyHtml()
    stance: json.stance ? ''
    headlineStance: json.headlineStance ? ''
    comment: json.comment
    createdBy: json.urlVersion.createdBy
    createdAt: json.urlVersion.createdAt
    createdAtString: moment(json.urlVersion.createdAt).format('YYYY-MM-DD \\a\\t h:mm A')

  getDataFromForm: ->
    urlVersion:
      source: @ui.source.val().trim()
      headline: @ui.headline.val().trim()
      byline: @ui.byline.val().trim()
      body: @ui.body.val().trim()
    stance: @ui.stance.filter(':checked').val() || null
    headlineStance: @ui.headlineStance.filter(':checked').val() || null
    comment: @ui.comment.val().trim()
