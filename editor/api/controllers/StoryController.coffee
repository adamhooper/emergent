Story = require('../../../data-store').models.Story

module.exports = self =
  index: (req, res) ->
    if req.method == 'POST'
      # FIXME aren't blueprints supposed to handle this for us?
      # This shouldn't be an if-statement
      self.create(req, res)
    else
      Story.findAll()
        .then (val) -> res.json(val)
        .catch (err) -> res.status(500).json(err)

  find: (req, res) ->
    slug = req.param('slug') || ''
    Story.find(where: { slug: slug })
      .then (val) ->
        if val?
          res.json(val)
        else
          res.status(404).json(message: "Could not find a story with slug '#{slug}'")
      .catch (err) -> res.status(400).json(err)

  create: (req, res) ->
    if !req.body?
      res.status(400).json(message: 'You must send the JSON properties to create')
    else
      Story.create(req.body, req.user.email)
        .then (val) -> res.json(val)
        .catch (err) -> res.status(400).json(err)

  destroy: (req, res) ->
    slug = req.param('slug') || ''
    Story.destroy(slug: slug)
      .then -> res.json({})
      .catch (err) -> res.status(500).json(err)

  update: (req, res) ->
    slug = req.param('slug') || ''
    if !req.body?
      res.status(400).json(message: 'You must send the JSON properties to update')
    else if req.body.slug?
      res.status(400).json(message: 'You can never change the slug of a story')
    else
      Story.find(where: { slug: slug })
        .then (story) ->
          if !story
            res.status(404).json(message: "Could not find a story with slug '#{slug}'")
          else
            Story.update(story, req.body, req.user.email)
              .then (updatedStory) -> res.json(updatedStory)
        .catch (err) -> res.status(500).json(err)
