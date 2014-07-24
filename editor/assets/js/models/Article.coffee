define [ 'underscore', 'backbone' ], (_, Backbone) ->
  class Article extends Backbone.Model
    defaults:
      url: ''
