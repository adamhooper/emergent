define [
  'jquery'
  '../collections/Stories'
  '../models/Story'
], ($, Stories, Story) ->
  # Exposes server-side API methods to a Backbone.Wreqr.RequestResponse
  installToReqres: (reqres) ->
    API =
      'stories/index': ->
        d = $.Deferred()
        stories = new Stories()
        stories.fetch
          success: (data) -> d.resolve(data)
          error: (err) -> d.reject(err)
        d.promise()

      'stories/show': (slug) ->
        d = $.Deferred()
        story = new Story(slug: slug)
        story.fetch
          success: -> d.resolve(story)
          error: (err) -> d.reject(err)
        d.promise()

      'stories/create': (data) ->
        d = $.Deferred()
        story = new Story(data, isNew: true)
        story.save
          success: -> d.resolve(story)
          error: (err) -> d.reject(err)
        d.promise()

    for key, cb of API when !reqres.hasHandler(key)
      reqres.setHandler(key, cb)
