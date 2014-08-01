define [
  'marionette'
  'views/StoryArticleListItemView'
  'views/StoryArticleListNoItemView'
], (
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
      @on('itemview:click', (view, model) => @trigger('click', model))
