define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class StoryView extends Marionette.ItemView
    template: _.template('''
      <div class="slug">
        <h3 class="slug"><%- slug %></h3>
        <a href="#" class="back"><i class="glyphicon glyphicon-arrow-left"></i> Back to all Stories</a>
      </div>
      <h2 class="headline"><%- headline %></h2>
      <p class="description"><%- description %></p>
      <p class="explanation">FIXME you should be able to edit these settings.</p>
    ''')

    events:
      'click a.back': 'onBack'

    onBack: (e) ->
      e.preventDefault()
      @trigger('back')
