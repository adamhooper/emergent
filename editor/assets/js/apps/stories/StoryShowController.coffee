define [ 'app', 'q' ], (App, Q) ->
  go: (slug) ->
    require [ 'models/Article', 'views/StoryShowLayout' ], (Article, StoryShowLayout) ->
      Q.all([
        App.request('stories/show', slug)
        App.request('story-articles/index', slug)
      ])
        .spread (story, articles) ->
          story.articles = articles
          story
        .then (story) ->
          layout = StoryShowLayout.forStoryInRegion(story, App.mainRegion)

          # TODO are there leaks with `.on` calls?
          layout.on 'articles:new', (data) ->
            story.articles.create(data)

          layout.on 'articles:delete', (cid) ->
            article = story.articles.get(cid)
            article.destroy()

          layout.on 'story:back', ->
            App.trigger('stories:list')

          story.articles.on 'change', (model, options) ->
            if options?.userInput
              console.log('Changed model', model)
              model.save()
