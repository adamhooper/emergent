Marionette = require('backbone.marionette')
StoryWithUnseenArticlesItemView = require('./StoryWithUnseenArticlesItemView')

module.exports = class StoryWithUnseenArticlesListView extends Marionette.CollectionView
  tagName: 'ul'
  className: 'stories-with-unseen-articles'
  childView: StoryWithUnseenArticlesItemView

  initialize: ->
    @on('childview:focus', (view, article) => @trigger('focus', article))
