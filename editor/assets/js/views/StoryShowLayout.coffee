define [
  'marionette'
  'views/StoryView'
  'views/StoryArticleListView'
  'views/NewStoryArticleView'
], (
  Marionette
  StoryView
  StoryArticleListView
  NewStoryArticleView
) ->
  class StoryShowLayout extends Marionette.Layout
    template: -> '''
      <div class="story-show-layout row">
        <div class="col-md-5">
          <div class="story-metadata"></div>
        </div>
        <div class="col-md-7">
          <h3>Articles about this story</h3>
          <div class="article-list"></div>
          <div class="new-article"></div>
        </div>
      </div>
      '''

    regions:
      story: '.story-metadata'
      articleList: '.article-list'
      newArticle: '.new-article'

    initialize: ->
      @story.on 'show', (view) =>
        if view?
          @listenTo(view, 'back', -> @trigger('story:back'))
      @story.on('close', ((view) => @stopListening(view) if view?))

      @newArticle.on 'show', (view) =>
        if view?
          @listenTo(view, 'submit', (data) -> @trigger('articles:new', data))
      @newArticle.on('close', ((view) => @stopListening(view) if view?))

      @articleList.on 'show', (view) =>
        if view?
          @listenTo(view, 'delete', (cid) -> @trigger('articles:delete', cid))
      @articleList.on('close', ((view) => @stopListening(view) if view?))

  StoryShowLayout.forStoryInRegion = (story, region) ->
    layout = new StoryShowLayout
    region.show(layout)

    layout.story.show(new StoryView(model: story))
    layout.articleList.show(new StoryArticleListView(collection: story.articles))
    layout.newArticle.show(new NewStoryArticleView)

    layout

  StoryShowLayout
