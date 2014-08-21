define [ 'backbone' ], (Backbone) ->
  class Story extends Backbone.Model
    idAttribute: 'slug'
    urlRoot: '/stories'

    defaults:
      slug: ''
      headline: ''
      description: ''
      origin: ''
      originUrl: null
      truthiness: 'unknown'
      truthinessDate: null

    initialize: (attributes, options) ->
      @_isNew = options?.isNew || false

    save: (args...) ->
      ret = super(args...)
      @_isNew = false
      ret

    isNew: ->
      @_isNew
