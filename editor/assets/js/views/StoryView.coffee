define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class StoryView extends Marionette.ItemView
    className: 'story'

    template: _.template('''
      <h3 class="slug"><%- slug %></h3>
      <h2 class="headline"><%- headline %></h2>
      <p class="description"><%- description %></p>
    ''')
