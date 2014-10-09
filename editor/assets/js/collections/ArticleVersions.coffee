Backbone = require('backbone')
ArticleVersion = require('../models/ArticleVersion')

module.exports = class ArticleVersions extends Backbone.Collection
  model: ArticleVersion
  url: -> "/articles/#{@articleId}/versions"

  initialize: (models, options) ->
    throw 'Must set options.articleId, a UUID' if !options.articleId

    @articleId = options.articleId
