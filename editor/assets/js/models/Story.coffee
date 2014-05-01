define [ 'backbone' ], (Backbone) ->
  class Story extends Backbone.Model
    idAttribute: 'slug'

    defaults:
      slug: ''
      description: ''
