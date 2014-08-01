define [
  'backbone'
], (Backbone) ->
  class ArticleVersion extends Backbone.Model
    defaults:
      truthiness: null
      comment: ''
      urlVersion:
        source: ''
        headline: ''
        publishedAt: null
        byline: ''
        body: ''
