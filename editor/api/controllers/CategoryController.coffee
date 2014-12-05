models = require('../../../data-store').models
Category = models.Category

module.exports =
  index: (req, res) ->
    Category.findAll(order: [[ 'name' ]])
      .then (categories) -> res.json(categories)
      .catch (e) -> res.status(500).send(e)
