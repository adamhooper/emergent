define [ 'jquery' ], ($) ->
  # Exposes server-side API methods to a Backbone.Wreqr.RequestResponse
  installToReqres: (reqres) ->
    API =
      'stories/index': ->
        d = $.Deferred()
        require [ 'collections/Stories' ], (Stories) ->
          stories = new Stories()
          stories.fetch
            success: (data) -> d.resolve(data)
            error: (err) -> d.reject(err)
        d.promise()

      'stories/create': (data) ->
        d = $.Deferred()
        require [ 'models/Story' ], (Story) ->
          story = new Story(data, isNew: true)
          story.save
            success: -> d.resolve(story)
            error: (err) -> d.reject(err)
        d.promise()

    for key, cb of API when !reqres.hasHandler(key)
      reqres.setHandler(key, cb)
