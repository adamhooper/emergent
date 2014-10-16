Marionette = require('backbone.marionette')
ArticleVersions = require('../collections/ArticleVersions')
ArticleVersionListView = require('./ArticleVersionListView')
ArticleVersionListPlaceholderView = require('./ArticleVersionListPlaceholderView')
StoryWithUnseenArticlesListView = require('./StoryWithUnseenArticlesListView')

module.exports = class UnseenArticleListLayout extends Marionette.LayoutView
  template: -> """
    <div class="unseen-article-list-layout">
      <h1>Unseen Updates</h1>
      <p class="explanation">Websites change behind your back. This page will show you all the updates you haven't seen. Please set their stances.</p>
      <div class="col-xs-4 articles">
      </div>
      <div class="col-xs-8 versions">
      </div>
    </div>
  """

  regions:
    articles: '.articles'
    versions: '.versions'

  initialize: ->
    @articles.on 'show', (view) =>
      if view?
        @listenTo(view, 'focus', (model) => @focusArticle(model))
    @articles.on('destroy', ((view) => @stopListening(view) if view?))

  focusArticle: (article) ->
    versions = new ArticleVersions([], articleId: article.id)
    versions.fetch
      success: -> versions.add({}) # a placeholder
    @versions.show(new ArticleVersionListView(collection: versions))
    @$('.focus').removeClass('focus')

UnseenArticleListLayout.forCollectionInRegion = (stories, region) ->
  layout = new UnseenArticleListLayout
  region.show(layout)

  layout.articles.show(new StoryWithUnseenArticlesListView(collection: stories))
  layout.versions.show(new ArticleVersionListPlaceholderView)
