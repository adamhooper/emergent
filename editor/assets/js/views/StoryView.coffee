define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class StoryView extends Marionette.ItemView
    className: 'story'

    template: _.template('''
      <h3 class="slug"><%- slug %></h3>
      <p class="actions"><a href="#" class="back"><span class="glyphicon glyphicon-arrow-left"></span> Back to all Stories</a></p>
      <h2 class="headline"><%- headline %></h2>
      <p class="description"><%- description %></p>
      <p class="explanation">FIXME you should be able to edit these settings.</p>
      <p class="explanation">Add Articles on the right to get a sense of how this story was told.</p>
    ''')

    events:
      'click a.back': 'onBack'

    onBack: (e) ->
      e.preventDefault()
      @trigger('back')
