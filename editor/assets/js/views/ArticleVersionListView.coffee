Marionette = require('backbone.marionette')
ArticleVersionItemView = require('./ArticleVersionItemView')

module.exports = class ArticleVersionListView extends Marionette.CollectionView
  tagName: 'ul'
  className: 'article-versions'
  childView: ArticleVersionItemView

  initialize: ->
