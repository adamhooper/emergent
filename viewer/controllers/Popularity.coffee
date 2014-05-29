Q = require('q')

stories = db.get('story')
articles = db.get('article')
storyArticles = db.get('article_story')
urls = db.get('url')
urlFetches = db.get('url_fetch')

Services = [ 'facebook', 'twitter', 'google' ]

module.exports =
  index: (req, res, next) ->
    Q.all [
      stories.find({}, fields: { slug: 1 })
      articles.find({}, fields: { storyId: 1, url: 1, truthiness: 1 })
      storyArticles.find({}, {})
      urls.find({}, {})
    ]
      .spread (stories, articles, storyArticles, urls) ->
        urlsByUrl = {}
        urlsByUrl[url.url] = url for url in urls

        articlesById = {}
        articlesById[article._id] = article for article in articles

        articlesByStoryId = {}
        for x in storyArticles
          y = articlesByStoryId[x.storyId] ||= []
          y.push(articlesById[x.articleId])

        for story in stories
          story.truthyShares =
            myth: { facebook: 0, twitter: 0, google: 0 }
            truth: { facebook: 0, twitter: 0, google: 0 }
            '': { facebook: 0, twitter: 0, google: 0 }

          story.nShares = 0
          for article in articlesByStoryId[story._id] || []
            truthiness = article.truthiness
            shares = urlsByUrl[article.url]?.shares || {}
            for service, info of shares
              n = info.n || 0
              story.truthyShares[truthiness][service] += n
              story.nShares += n

        stories
      .then (stories) ->
        res.render('Popularity/index', { stories: stories })
      .catch(next)
