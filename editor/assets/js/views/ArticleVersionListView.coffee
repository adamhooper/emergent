define [
  'marionette'
  './ArticleVersionItemView'
], (Marionette, ArticleVersionItemView) ->
  class ArticleVersionListView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'article-versions'
    itemView: ArticleVersionItemView

    initialize: ->
