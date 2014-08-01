define [
  'backbone'
  'models/ArticleVersion'
], (Backbone, ArticleVersion) ->
  class ArticleVersions extends Backbone.Collection
    model: ArticleVersion
    url: -> "/articles/#{@articleId}/versions"

    initialize: (models, options) ->
      throw 'Must set options.articleId, a UUID' if !options.articleId

      @articleId = options.articleId
