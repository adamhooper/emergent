define [ 'backbone' ], (Backbone) ->
  class Article extends Backbone.Model
    defaults:
      url: ''
      source: ''
      headline: ''
      author: ''
      body: ''
      truthiness: ''
