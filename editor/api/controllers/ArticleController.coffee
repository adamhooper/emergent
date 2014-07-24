Promise = require('bluebird')

Story = global.models.Story
Article = global.models.Article
Url = global.models.Url

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
        res.json(404, "Story '#{slug}' not found")
      else
        cb(story)
    .catch((err) -> res.json(err.status || 500, err))

# Sends a 400 error if request body is invalid; otherwise calls next(validBody)
validUrl = (req, res, next) ->
  url = req.body?.url

  if !_.isString(url)
    res.json(400, 'You must send a JSON object that looks like "{ url: \"http://example.org\" }"')
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
          res.json(err.status || 500, err)

  create: (req, res) ->
    validUrl req, res, (url) ->
      findStoryThen req, res, (story) ->
        Url.upsert({ url: url }, req.user.email)
          .spread (urlObject, isNew) ->
            if isNew
              job = global.kueQueue.createJob('url', incoming: urlObject.toJSON())
              Promise.promisify(job.save, job)()
                .then(-> urlObject)
            else
              urlObject
          .then (urlObject) ->
            Article.upsert({ storyId: story.id, urlId: urlObject.id }, req.user.email)
              .spread (article) ->
                json = article.toJSON()
                json.url = url
                json
          .then((json) -> res.json(json))
          .catch (err) ->
            if /^Validation/.test(err?.url?[0]?.message || '')
              res.json(400, err)
            else
              # If the Url wasn't created, we return that error.
              #
              # If the Article wasn't created, we've left a Url in the database
              # but that isn't a big deal.
              #
              # If the queueing didn't work, we've left an Article in the
              # database and reported an error to the user. That will have to do.
              console.warn(err, err.stack)
              res.json(err.status || 500, err)

  destroy: (req, res) ->
    articleId = req.param('id')

    findStoryThen req, res, (story) ->
      Article.destroy(storyId: story.id, id: articleId)
        .then(-> res.json({}))
        .catch((e) -> res.json(e.status || 500, e))
