Marionette = require('backbone.marionette')
StoryListItemView = require('./StoryListItemView')
StoryListNoItemView = require('./StoryListNoItemView')

module.exports = class StoryListView extends Marionette.CollectionView
  tagName: 'ul'
  className: 'story-list'
  childView: StoryListItemView
  emptyView: StoryListNoItemView

  initialize: ->
    propagateEventWithSlug = (event) =>
      @on "itemview:#{event}", (itemView) =>
        @trigger(event, itemView.model.id)

    propagateEventWithSlug(event) for event in [ 'click', 'delete' ]
