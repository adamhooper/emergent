define [
  'marionette'
  'views/StoryArticleListItemView'
], (
  Marionette
  StoryArticleListItemView
) ->
  class StoryArticleListView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'story-articles'
    itemView: StoryArticleListItemView

    initialize: ->
      @on('itemview:click', @onClick)
      @on('itemview:create', @onCreate)

    onClick: (view, model) ->
      @setFocusView(view)
      @trigger('focus', model)

    onCreate: (view, model) ->
      @collection.add({})

    setFocusView: (view) ->
      @focusView.$el.removeClass('focus') if @focusView?
      @focusView = view
      @focusView.$el.addClass('focus') if @focusView?
