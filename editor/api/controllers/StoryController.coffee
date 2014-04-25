module.exports = self =
  index: (req, res) ->
    if req.method == 'POST'
      # FIXME aren't blueprints supposed to handle this for us?
      # This shouldn't be an if-statement
      self.create(req, res)
    else
      Story.find()
        .then (val) -> res.json(val)
        .fail (err) -> res.json(500, err)
        .done()

  create: (req, res) ->
    if !req.body?
      res.json(400, 'You must send the JSON properties to create')
    else if req.body.createdBy?
      res.json(400, 'You cannot manually set the createdBy of a story: it will always be you')
    else if req.body.updatedBy?
      res.json(400, 'You cannot manually set the updatedBy of a story: it will always be you')
    else
      story = {}
      for k, v of req.body
        story[k] = v
      story.createdBy = req.user.email
      story.updatedBy = req.user.email

      Story.create(story)
        .then (val) -> res.json(val)
        .fail (err) ->
          if /^Error: Uniqueness check failed/.test(err?.originalError?[0]?.toString())
            err =
              status: 400
              summary: 'Uniqueness check failed'

          if err.status
            res.json(err.status, err)
          else
            res.json(500, err)
        .done()

  destroy: (req, res) ->
    slug = req.param('id') || ''
    Story.destroy(slug: slug)
      .then -> res.json({})

  update: (req, res) ->
    slug = req.param('id') || ''
    if !req.body?
      res.json(400, 'You must send the JSON properties to update')
    else if req.body.slug?
      res.json(400, 'You can never change the slug of a story')
    else if req.body.createdBy?
      res.json(400, 'You cannot change the createdBy of a story')
    else if req.body.updatedBy?
      res.json(400, 'You cannot manually set the updatedBy of a story: it will always be you')
    else
      story = {}
      for k, v of req.body
        story[k] = v
      story.updatedBy = req.user.email
      Story.update({ slug: slug }, story)
        .then (vals) ->
          if vals.length == 0
            res.json(404, {})
          else
            res.json(vals[0])
        .done()
