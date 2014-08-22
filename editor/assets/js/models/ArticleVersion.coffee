define [
  'backbone'
], (Backbone) ->
  class ArticleVersion extends Backbone.Model
    defaults:
      stance: null
      headlineStance: null
      comment: ''
      urlVersion:
        source: ''
        headline: ''
        publishedAt: null
        byline: ''
        body: ''
