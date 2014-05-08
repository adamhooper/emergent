define [
  'underscore'
  'marionette'
  'views/StoryArticleListItemView'
  'views/StoryArticleListNoItemView'
], (
  _
  Marionette
  StoryArticleListItemView
  StoryArticleListNoItemView
) ->
  class StoryArticleListView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'story-articles'
    itemView: StoryArticleListItemView
    emptyView: StoryArticleListNoItemView

    initialize: ->
      @on 'itemview:delete', (itemView, args...) =>
        @trigger('delete', itemView.model.cid, args...)
