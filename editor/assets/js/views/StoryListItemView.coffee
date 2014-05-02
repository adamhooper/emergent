define [ 'marionette' ], (Marionette) ->
  class StoryListItemView extends Marionette.ItemView
    tagName: 'li'
    className: 'story-list-item'

    template: _.template('''
      <h4 class="slug"><%- slug %></h4>
      <h3 class="headline"><%- headline %></h3>
      <p class="description"><%- description %></p>
      <button class="delete btn btn-danger">Delete</button>
    ''')

    events:
      'click .delete': 'onDelete'

    onDelete: (e) ->
      e.preventDefault()
      if window.confirm('Are you sure you want to delete this story? This cannot be undone.')
        @trigger('delete')
