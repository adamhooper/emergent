define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class StoryArticleListItemCollapsedView extends Marionette.ItemView
    tagName: 'li'

    template: _.template('''
      <a href="#"><%- url %></a>
    ''')

    events:
      'submit form': 'onSubmit'
      'click a': 'onClick'

    onClick: (e) ->
      e.preventDefault()
      @trigger('click', @model)

    render: ->
      super()
      @el.className = if @expanded then 'article article-expanded' else 'article article-collapsed'
      this
