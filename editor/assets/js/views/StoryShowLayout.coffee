Marionette = require('backbone.marionette')
ArticleVersions = require('../collections/ArticleVersions')
StoryView = require('./StoryView')
StoryArticleListView = require('./StoryArticleListView')
ArticleVersionListView = require('./ArticleVersionListView')
ArticleVersionListPlaceholderView = require('./ArticleVersionListPlaceholderView')

module.exports = class StoryShowLayout extends Marionette.LayoutView
  className: 'container story-show-layout'

  template: -> '''
    <div class="row">
      <div class="col-xs-12">
        <div class="story-metadata"></div>
      </div>
    </div>
    <div class="row">
      <div class="col-md-6">
        <h3>Articles about this story</h3>
        <div class="article-list"></div>
      </div>
      <div class="col-md-6">
        <h3>Versions</h3>
        <div class="article-version-list"></div>
      </div>
    </div>
    '''

  regions:
    story: '.story-metadata'
    articleList: '.article-list'
    articleVersionList: '.article-version-list'

  initialize: ->
    @story.on 'show', (view) =>
      if view?
        @listenTo(view, 'back', => @trigger('story:back'))
    @story.on('destroy', ((view) => @stopListening(view) if view?))

    @articleList.on 'show', (view) =>
      if view?
        @listenTo(view, 'focus', (model) => @focusArticle(model))
    @articleList.on('destroy', ((view) => @stopListening(view) if view?))

  focusArticle: (article) ->
    versions = new ArticleVersions([], articleId: article.id)
    versions.fetch
      success: -> versions.add({}) # a placeholder
    @articleVersionList.show(new ArticleVersionListView(collection: versions))
    @$el.addClass('article-focused')

StoryShowLayout.forStoryInRegion = (story, region) ->
  layout = new StoryShowLayout
  region.show(layout)

  story.articles.add({}) # a placeholder

  layout.story.show(new StoryView(model: story))
  layout.articleList.show(new StoryArticleListView(collection: story.articles))
  layout.articleVersionList.show(new ArticleVersionListPlaceholderView)

  layout

StoryShowLayout
