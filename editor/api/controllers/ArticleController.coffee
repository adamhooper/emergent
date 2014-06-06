Q = require('q')

ValidAttributesAndDefaults =
  url: null
  truthiness: ''
  source: ''
  author: ''
  headline: ''
  body: ''
  publishedAt: (v) ->
    if !v? || v == ''
      null
    else
      new Date(v)

attributesToArticle = (attrs) ->
  ret = {}
  for k, v of ValidAttributesAndDefaults
    ret[k] = if _.isFunction(v)
      v(attrs[k])
    else
      attrs[k] || v
  ret

# Returns a Story.findOne() query. Call .exec() or treat it as a Promise.
findStory = (req) ->
  Story = sails.models.story
  slug = req.param('slug') || ''

  sails.models.story.findOne(slug: slug)

# Finds the story based on the request parameters.
#
# Writes to res.json() if there is an error:
#
# * Database layer error: status 500 (or whatever Sails gives)
# * Not found: status 404
#
# Usage:
#
#     findStoryThen req, res, (story) ->
#       # assume story is here; if it isn't, res has been written to
#       res.json(story.toJSON())
findStoryThen = (req, res, cb) ->
  findStory(req).exec (err, story) ->
    if err?
      res.json(err.status || 500, err)
    else if !story
      res.json(404, "Story '#{req.param('slug')}' not found")
    else
      cb(story)

# Sends a 400 error if request body is invalid; otherwise calls next(validBody)
validBody = (req, res, next) ->
  if !req.body?
    res.json(400, 'You must send the JSON properties to this method')
  else
    next(req.body)

module.exports = self =
  index: (req, res) ->
    findStoryThen req, res, (story) ->
      sails.models.article_story.find().where(storyId: story.id.toString())
        .then (assoc) ->
          if assoc.length
            sails.models.article.find().where(id: (x.articleId.toString() for x in assoc))
          else
            []
        .then (articles) ->
          res.json(articles)
        .fail (err) ->
          res.json(err.status || 500, err)
        .done()

  create: (req, res) ->
    validBody req, res, (body) ->
      findStoryThen req, res, (story) ->
        data = attributesToArticle(body)
        data.createdBy = req.user.email
        data.updatedBy = req.user.email

        sails.models.article.findOrCreate({ url: data.url }, data)
          .then (article) ->
            assoc =
              storyId: story.id.toString()
              articleId: article.id.toString()
            sails.models.article_story.findOrCreate(assoc, assoc).then(-> article)
          .then (article) ->
            Q.nsend(global.kueQueue.createJob('url', incoming: article.url), 'save').then(-> article)
          .then (article) ->
            res.json(article.toJSON())
          .catch (err) ->
            # If the article wasn't created, we return that error.
            #
            # If the article was created but the association wasn't, we
            # return an error and leave the Article in the database. That's
            # fine -- a find-or-create in the future will succeed, and
            # there's no harm to having an extra Article lying around.
            res.json(err.status || 500, err)
          .done()

  update: (req, res) ->
    articleId = req.param('id')

    validBody req, res, (body) ->
      findStoryThen req, res, (story) ->
        data = attributesToArticle(body)
        data.updatedBy = req.user.email

        # We don't check whether the article belongs to this story. That opens
        # up a world of race conditions, and we don't have a security issue
        # here because all updates are trusted (and logged).
        sails.models.article.update(articleId, data)
          .then (articles) ->
            if !articles.length
              res.json(404, "Could not find Article with if #{articleId} in Story with slug #{req.param('slug')}")
            else
              Q.nsend(global.kueQueue.createJob('url', incoming: data.url), 'save')
                .then(-> res.json(articles[0]))
          .catch((err) -> res.json(err.status || 500, err))

  destroy: (req, res) ->
    articleId = req.param('id')

    findStoryThen req, res, (story) ->
      assoc = 
        storyId: story.id
        articleId: articleId
      Q(sails.models.article_story.destroy(assoc))
        .then(-> res.json({}))
        .catch((err) -> res.json(err.status || 500, err))
        .done()
