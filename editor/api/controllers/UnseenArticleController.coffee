module.exports =
  index: (req, res) ->
    models.Article.findAllWithUnseenVersion({}, raw: true)
      .then (articles) ->
        articleIds = (a.id for a in articles)
        storyIds = (a.storyId for a in articles)
        urlIds = (a.urlId for a in articles)
        Promise.all([
          models.Story.findAll({ where: { id: storyIds }}, raw: true)
          models.Url.findAll({ where: { id: urlIds }}, raw: true)
        ])
          .spread (stories, urls) ->
            urlIdToUrl = {}
            (urlIdToUrl[u.id] = u.url) for u in urls

            storyIdToStory = {}
            slugToStory = {}
            for story in stories
              storyIdToStory[story.id] = story
              slugToStory[story.slug] = story

            # Add article.url, story.articles
            (s.articles = []) for s in stories
            for article in articles
              article.url = urlIdToUrl[article.urlId]
              story = storyIdToStory[article.storyId]
              story.articles.push(article)

            slugs = Object.keys(slugToStory)
            slugToStory[slug] for slug in slugs.sort()

      .then((stories) -> res.json(stories))
      .catch((e) -> res.status(e.status || 500).json(e))
