# Returns a Story.findOne() query. Call .exec() or treat it as a Promise.
findStory = (req) ->
  Story = sails.models.story
  slug = req.param('slug') || ''

  sails.models.story.findOne(slug: slug)

# Sends a 400 error if request body is invalid; otherwise calls next(validBody)
validBody = (req, res, next) ->
  if !req.body?
    res.json(400, 'You must send the JSON properties to create')
  else if req.body.createdBy?
    res.json(400, 'You cannot manually set the createdBy of a story: it will always be you')
  else if req.body.updatedBy?
    res.json(400, 'You cannot manually set the updatedBy of a story: it will always be you')
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
      findStory(req)
        .exec (err, story) ->
          if err?
            res.json(err.status || 500, err)
          else if !story?
            res.json(404, "Story '#{req.param('slug')}' not found")
          else
            data = {}
            for k, v of body
              data[k] = v
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

  destroy: (req, res) ->
    articleId = req.param('id')

    findStory(req)
      .exec (err, story) ->
        if err?
          res.json(err.status || 500, err)
        else if !story?
          res.json(404, "Story '#{req.param('slug')}' not found")
        else
          assoc = 
            story_articles: story.id
            article_stories: articleId
          Q(sails.models.article_stories__story_articles.destroy(assoc))
            .then(-> res.json({}))
            .catch((err) -> res.json(err.status || 500, err))
            .done()
