Promise = require('bluebird')

models = require('../../data-store').models

module.exports =
  'get /url-gets/:urlGetId.html': (req, res, next) ->
    models.UrlGet.find(req.params.urlGetId)
      .tap (urlGet) ->
        if !urlGet?
          res.status(404)
          throw new Error('UrlGet not found')
      .then (urlGet) -> urlGet.body
      .then (html) ->
        res.header('content-type', 'text/html')
        res.send(html)
      .catch(next)
