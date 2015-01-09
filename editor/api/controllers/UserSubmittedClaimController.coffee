validator = require('validator')
_ = require('lodash')

models = require('../../../data-store').models

module.exports =
  index: (req, res) ->
    models.UserSubmittedClaim.findAll({
      where: { spam: false, archived: false }
      order: [[ 'createdAt' ]]
    })
      .then((val) -> res.json(val))
      .catch((err) -> res.status(500).json(err))

  update: (req, res) ->
    attributes = {}
    attributes.spam = Boolean(req.body.spam) if req.body?.spam?
    attributes.archived = Boolean(req.body.archived) if req.body?.archived?

    if !validator.isUUID(req.params.id)
      return res.status(404).json(message: 'You must pass a valid UUID')
    if !attributes.spam? && !attributes.archived?
      return res.status(400).json(message: 'You must set a "spam" or "archived" boolean attribute')

    models.UserSubmittedClaim.partialUpdate({ id: req.params.id }, attributes, req.user.email)
      .then (nRows) -> 
        if nRows == 0
          res.status(404).json(message: "There is no UserSubmittedClaim with id=#{req.params.id}")
        else
          res.status(204).send()
      .catch((err) -> console.warn(err.stack); res.status(500).json(err))
