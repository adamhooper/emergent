define [
  'jquery'
  'q'
  '../collections/Articles'
], ($, Q, Articles) ->
  # Exposes server-side API methods to a Backbone.Wreqr.RequestResponse
  installToReqres: (reqres) ->
    API =
      'story-articles/index': (slug) ->
        d = Q.defer()
        articles = new Articles()
        articles.storySlug = slug
        articles.fetch
          success: (data) -> d.resolve(data)
          error: (err) -> d.reject(err)
        d.promise

    for key, cb of API when !reqres.hasHandler(key)
      reqres.setHandler(key, cb)
