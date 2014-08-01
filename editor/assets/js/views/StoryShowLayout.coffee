define [
  'marionette'
  'collections/ArticleVersions'
  'views/StoryView'
  'views/StoryArticleListView'
  'views/NewStoryArticleView'
  'views/ArticleVersionListView'
  'views/ArticleVersionListPlaceholderView'
], (
  Marionette
  ArticleVersions
  StoryView
  StoryArticleListView
  NewStoryArticleView
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
          <div class="new-article"></div>
        </div>
        <div class="col-md-6">
          <div class="article-version-list"></div>
        </div>
      </div>
      '''

    regions:
      story: '.story-metadata'
      articleList: '.article-list'
      newArticle: '.new-article'
      articleVersionList: '.article-version-list'

    initialize: ->
      @story.on 'show', (view) =>
        if view?
          @listenTo(view, 'back', -> @trigger('story:back'))
      @story.on('close', ((view) => @stopListening(view) if view?))

      @newArticle.on 'show', (view) =>
        if view?
          @listenTo(view, 'show', (data) -> @trigger('articles:show', data))
          @listenTo(view, 'submit', (data) -> @trigger('articles:new', data))
      @newArticle.on('close', ((view) => @stopListening(view) if view?))

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

    layout.story.show(new StoryView(model: story))
    layout.articleList.show(new StoryArticleListView(collection: story.articles))
    layout.newArticle.show(new NewStoryArticleView)
    layout.articleVersionList.show(new ArticleListPlaceholderView)

    layout

  StoryShowLayout
