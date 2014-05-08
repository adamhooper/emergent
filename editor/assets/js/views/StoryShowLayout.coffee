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
      <div class="row">
        <div class="col-md-5">
          <div class="story"></div>
        </div>
        <div class="col-md-7">
          <div class="article-list"></div>
          <div class="new-article"></div>
        </div>
      </div>
      '''

    regions:
      story: '.story'
      articleList: '.article-list'
      newArticle: '.new-article'

    initialize: ->
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
