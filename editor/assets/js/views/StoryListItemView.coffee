define [ 'marionette' ], (Marionette) ->
  class StoryListItemView extends Marionette.ItemView
    tagName: 'li'
    className: 'story-list-item'

    template: _.template('''
      <button class="delete btn btn-danger">Delete</button>
      <h4 class="slug"><a href="#"><%- slug %></a></h4>
      <h3 class="headline"><a href="#"><%- headline %></a></h3>
      <p class="description"><%- description %></p>
    ''')

    events:
      'click a': 'onClick'
      'click .delete': 'onDelete'

    onClick: (e) ->
      e.preventDefault()
      @trigger('click')

    onDelete: (e) ->
      e.preventDefault()
      if window.confirm('Are you sure you want to delete this story? This cannot be undone.')
        @trigger('delete')
