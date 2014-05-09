define [
  'marionette'
  'views/StoryListItemView'
  'views/StoryListNoItemView'
], (Marionette, StoryListItemView, StoryListNoItemView) ->
  class StoryListView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'story-list'
    itemView: StoryListItemView
    emptyView: StoryListNoItemView

    initialize: ->
      propagateEventWithSlug = (event) =>
        @on "itemview:#{event}", (itemView) =>
          @trigger(event, itemView.model.id)

      propagateEventWithSlug(event) for event in [ 'click', 'delete' ]
