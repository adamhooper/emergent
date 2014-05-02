define [ 'backbone' ], (Backbone) ->
  class Story extends Backbone.Model
    idAttribute: 'slug'
    urlRoot: '/story'

    defaults:
      slug: ''
      headline: ''
      description: ''

    initialize: (attributes, options) ->
      @_isNew = options?.isNew || false

    save: (args...) ->
      ret = super(args...)
      @_isNew = false
      ret

    isNew: ->
      @_isNew
