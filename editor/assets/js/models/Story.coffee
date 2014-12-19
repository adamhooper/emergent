Backbone = require('backbone')

module.exports = class Story extends Backbone.Model
  idAttribute: 'slug'
  urlRoot: '/stories'

  defaults:
    slug: ''
    headline: ''
    description: ''
    origin: ''
    originUrl: null
    published: false
    truthiness: 'unknown'
    truthinessDate: null
    categories: []
    tags: []

  initialize: (attributes, options) ->
    @_isNew = options?.isNew || false

  save: (args...) ->
    ret = super(args...)
    @_isNew = false
    ret

  isNew: ->
    @_isNew
