define [
  'backbone'
], (Backbone) ->
  class Article extends Backbone.Model
    defaults:
      url: ''
