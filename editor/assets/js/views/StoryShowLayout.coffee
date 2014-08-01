define [
  'marionette'
  'collections/ArticleVersions'
  'views/StoryView'
  'views/StoryArticleListView'
  'views/ArticleVersionListView'
  'views/ArticleVersionListPlaceholderView'
], (
  Marionette
  ArticleVersions
  StoryView
  StoryArticleListView
  ArticleVersionListView
  ArticleVersionListPlaceholderView
) ->
  class StoryShowLayout extends Marionette.Layout
    className: 'story-show-layout'

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
          @listenTo(view, 'back', -> @trigger('story:back'))
      @story.on('close', ((view) => @stopListening(view) if view?))

      @articleList.on 'show', (view) =>
        if view?
          @listenTo(view, 'focus', (model) => @focusArticle(model))
      @articleList.on('close', ((view) => @stopListening(view) if view?))

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
    layout.articleVersionList.show(new ArticleListPlaceholderView)

    layout

  StoryShowLayout
