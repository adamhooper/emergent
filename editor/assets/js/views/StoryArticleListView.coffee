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
      @on('itemview:click', @onClick)

    onClick: (view, model) ->
      @setFocusView(view)
      @trigger('focus', model)

    setFocusView: (view) ->
      @focusView.$el.removeClass('focus') if @focusView?
      @focusView = view
      @focusView.$el.addClass('focus') if @focusView?
