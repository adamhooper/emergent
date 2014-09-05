_ = require('lodash')

models = require('../../data-store').models

claimToJson = (claim) ->
  _.pick(claim, [
    'slug'
    'headline'
    'description'
    'origin'
    'originUrl'
    'truthiness'
    'truthinessDate'
  ])

module.exports =
  'get /claims': (req, res, next) ->
    models.Story.findAll()
      .then((claims) -> { claims: claims.map(claimToJson) })
      .then((json) -> res.json(json))
      .catch(next)

  'get /claims/:slug': (req, res, next) ->
    models.Story.find(where: { slug: req.params.slug })
      .tap (claim) ->
        if !claim?
          res.status(404)
          throw new Error("Claim not found")
      .then(claimToJson)
      .then((json) -> res.json(json))
      .catch(next)
