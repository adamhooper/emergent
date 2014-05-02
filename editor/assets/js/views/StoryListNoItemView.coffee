define [ 'marionette' ], (Marionette) ->
  class StoryListNoItemView extends Marionette.ItemView
    tagName: 'li'
    className: 'empty'
    template: -> 'We have no stories'
