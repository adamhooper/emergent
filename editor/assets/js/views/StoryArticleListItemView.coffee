_ = require('lodash')
Marionette = require('backbone.marionette')

module.exports = class StoryArticleListItemCollapsedView extends Marionette.ItemView
  tagName: 'li'
  className: 'article'

  template: _.template('''
    <% if (!isNew) { %>
      <button class="delete" href="#" title="delete"><i class="glyphicon glyphicon-remove"></i></button>
      <a class="open" href="<%- url %>" target="_blank" title="open (in new tab)"><i class="glyphicon glyphicon-link"></i></a>
      <a class="select" href="#"><%- url %></a>
    <% } else { %>
      <form method="post" action="#">
        <div class="input-group">
          <input name="url" class="form-control" placeholder="http://url.related.to/this/story">
          <span class="input-group-btn">
            <button type="submit" class="btn btn-primary">Add</button>
          </span>
        </div>
      </form>
    <% } %>
  ''')

  ui:
    url: 'input[name=url]'

  events:
    'submit form': 'onSubmit'
    'click a.select': 'onClick'
    'click button.delete': 'onDelete'

  serializeData: ->
    json = @model.toJSON()

    isNew: @model.isNew()
    url: json.url

  onClick: (e) ->
    e.preventDefault()
    @trigger('click', @model)

  onDelete: (e) ->
    if window.confirm("You're about to remove this URL from the story: #{@model.get('url')}")
      e.preventDefault()
      @model.destroy()

  onSubmit: (e) ->
    e.preventDefault()

    url = @ui.url.val().trim()

    if url
      @model.save({ url: url }, {
        success: (model, response) => @onSubmitSuccess(response)
        error: (model, response) => @onSubmitError(response)
      })
      @$('.input-group-btn').replaceWith('<span class="input-group-addon form-control-feedback"><i class="spin">⟳</i></span>')
      @$('input').prop('disabled', true)
      @trigger('create', @model)

  onSubmitSuccess: (response) ->
    @render()

  onSubmitError: (response) ->
    @$('.form-control-feedback').replaceWith('<span class="input-group-addon form-control-feedback"><i class="error">✘</i></span>')
    @$el.addClass('has-error')
