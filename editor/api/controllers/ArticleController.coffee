Promise = require('bluebird')
_ = require('lodash')

Story = global.models.Story
Article = global.models.Article
ArticleVersion = global.models.ArticleVersion
Url = global.models.Url
UrlVersion = global.models.UrlVersion

# Returns a Url object from the database.
#
# Tells job-queue about this URL if it's new.
upsertUrl = (url, email) ->
  Url.upsert({ url: url }, email)
    .tap ([ urlObject, isNew ]) ->
      if isNew
        queueJob = Promise.promisify(global.urlJobQueue.queue, global.urlJobQueue)
        queueJob(id: urlObject.id, url: url)
    .then ([ urlObject ]) -> urlObject

# Returns Article, a JSON object that _inclues_ url: url.url and urlId: url.id
upsertArticle = (storyId, url, email) ->
  Article.upsert({ storyId: storyId, urlId: url.id }, email)
    .then ([ article ]) -> _.extend({}, article.toJSON(), url: url.url, urlId: url.id)

# Creates ArticleVersions for existing UrlVersions
#
# This has to be an upsert. For new Urls, there's a race: if the url fetcher
# sees this Article it's going to try to build ArticleVersions for it, too.
upsertArticleVersions = (article, email) ->
  urlVersions = UrlVersion.findAll(where: { urlId: article.urlId })
  Promise.map(urlVersions, (uv) -> ArticleVersion.upsert({ urlVersionId: uv.id, articleId: article.id }, email))

# Finds the story based on the request parameters.
#
# Writes to res.json() if there is an error:
#
# * Database layer error: status 500
# * Not found: status 404
#
# Usage:
#
#     findStoryThen req, res, (story) ->
#       # assume story is here; if it isn't, res has been written to
#       res.json(story.toJSON())
findStoryThen = (req, res, cb) ->
  slug = req.param('slug') || ''
  Story.find(where: { slug: slug })
    .then (story) ->
      if !story
        res.status(404).json("Story '#{slug}' not found")
      else
        cb(story)
    .catch((err) -> res.status(err.status || 500).json(err))

# Sends a 400 error if request body is invalid; otherwise calls next(validBody)
validUrl = (req, res, next) ->
  url = req.body?.url

  if !_.isString(url)
    res.status(400).json(message: 'You must send a JSON object that looks like "{ url: \"http://example.org\" }"')
  else
    next(url)

module.exports = self =
  index: (req, res) ->
    findStoryThen req, res, (story) ->
      Article.findAll(where: { storyId: story.id })
        .then (articles) ->
          if articles.length
            # Join urls as article.url
            Url.findAll(where: { id: { in: articles.map((a) -> a.urlId) } })
              .then (urls) ->
                urlById = {}
                (urlById[url.id] = url.url) for url in urls
                json = for article in articles
                  retItem = article.toJSON()
                  retItem.url = urlById[article.urlId]
                  retItem
                res.json(json)
          else
            res.json([])
        .catch (err) ->
          console.log(err)
          res.status(err.status || 500).json(err)

  create: (req, res) ->
    validUrl req, res, (url) ->
      findStoryThen req, res, (story) ->
        upsertUrl(url, req.user.email)
          .then((urlId) -> upsertArticle(story.id, urlId, req.user.email))
          .tap((json) -> upsertArticleVersions(json, req.user.email))
          .then((json) -> res.status(201).json(json))
          .catch (err) ->
            if /^Validation/.test(err.message)
              res.status(400).json(err)
            else
              # If the Url wasn't created, we return that error.
              #
              # If the Article wasn't created, we've left a Url in the database
              # but that isn't a big deal.
              #
              # If the queueing didn't work, we've left an Article in the
              # database and reported an error to the user. That will have to do.
              console.warn(err, err.stack)
              res.status(err.status || 500).json(err)

  destroy: (req, res) ->
    articleId = req.param('id')

    findStoryThen req, res, (story) ->
      Article.destroy(where: { storyId: story.id, id: articleId })
        .then(-> res.json({}))
        .catch((e) -> res.status(e.status || 500).json(e))
