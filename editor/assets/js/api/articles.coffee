$ = require('jquery')
Promise = require('bluebird')
Articles = require('../collections/Articles')

module.exports =
  # Exposes server-side API methods to a Backbone.Wreqr.RequestResponse
  installToReqres: (reqres) ->
    API =
      'story-articles/index': (slug) ->
        new Promise (resolve, reject) ->
          articles = new Articles()
          articles.storySlug = slug
          articles.fetch
            success: (data) -> resolve(data)
            error: (err) -> reject(err)

    for key, cb of API when !reqres.hasHandler(key)
      reqres.setHandler(key, cb)
