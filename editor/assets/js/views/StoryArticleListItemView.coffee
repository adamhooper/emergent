define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class StoryArticleListItemCollapsedView extends Marionette.ItemView
    tagName: 'li'
    className: 'article'

    template: _.template('''
      <a href="#"><%- url %></a>
    ''')

    events:
      'submit form': 'onSubmit'
      'click a': 'onClick'

    onClick: (e) ->
      e.preventDefault()
      @trigger('click', @model)
