define [
  'marionette'
  'views/StoryListItemView'
  'views/StoryListNoItemView'
], (Marionette, StoryListItemView, StoryListNoItemView) ->
  class StoryListView extends Marionette.CollectionView
    tagName: 'ul'
    itemView: StoryListItemView
    emptyView: StoryListNoItemView

    initialize: ->
      @on 'itemview:delete', (itemView) =>
        @trigger('delete', itemView.model.id)
