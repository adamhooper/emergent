Q = require('q')

ValidAttributesAndDefaults = {
  url: null
  truthiness: ''
  source: ''
  author: ''
  headline: ''
  body: ''
}

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
    findStory(req)
      .populate('articles')
      .exec (err, story) ->
        if err?
          res.json(err.status || 500, err)
        else if !story?
          res.json(404, "Story '#{req.param('slug')}' not found")
        else
          res.json(story.toJSON().articles)

  create: (req, res) ->
    validBody req, res, (body) ->
      findStoryThen req, res, (story) ->
        data = {}
        for k, v of ValidAttributesAndDefaults
          data[k] = body[k] || v
        data.createdBy = req.user.email
        data.updatedBy = req.user.email

        Q(sails.models.article.findOrCreate(data, data))
          .then (article) ->
            assoc =
              story_articles: story.id
              article_stories: article.id

            Q(sails.models.article_stories__story_articles.findOrCreate(assoc, assoc))
              .then(-> article)
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
        data = {}
        for k, v of ValidAttributesAndDefaults
          data[k] = body[k] || v
        data.updatedBy = req.user.email

        # We don't check whether the article belongs to this story. That opens
        # up a world of race conditions, and we don't have a security issue
        # here because all updates are trusted (and logged).
        sails.models.article.update(articleId, data)
          .then (articles) ->
            if !articles.length
              res.json(404, "Could not find Article with if #{articleId} in Story with slug #{req.param('slug')}")
            else
              res.json(articles[0])
          .catch((err) -> res.json(err.status || 500, err))

  destroy: (req, res) ->
    articleId = req.param('id')

    findStoryThen req, res, (story) ->
      assoc = 
        story_articles: story.id
        article_stories: articleId
      Q(sails.models.article_stories__story_articles.destroy(assoc))
        .then(-> res.json({}))
        .catch((err) -> res.json(err.status || 500, err))
        .done()
