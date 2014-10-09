Marionette = require('backbone.marionette')
StoryArticleListItemView = require('./StoryArticleListItemView')

module.exports = class StoryArticleListView extends Marionette.CollectionView
  tagName: 'ul'
  className: 'story-articles'
  childView: StoryArticleListItemView

  initialize: ->
    @on('childview:click', @onClick)
    @on('childview:create', @onCreate)

  onClick: (view, model) ->
    @setFocusView(view)
    @trigger('focus', model)

  onCreate: (view, model) ->
    @collection.add({})

  setFocusView: (view) ->
    @focusView.$el.removeClass('focus') if @focusView?
    @focusView = view
    @focusView.$el.addClass('focus') if @focusView?
