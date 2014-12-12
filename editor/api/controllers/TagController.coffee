models = require('../../../data-store').models
Tag = models.Tag

module.exports =
  index: (req, res) ->
    Tag.findAll(order: [[ 'name' ]])
      .then (tags) -> res.json(tags)
      .catch (e) -> res.status(500).send(e)
