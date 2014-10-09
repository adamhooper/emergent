Backbone = require('backbone')
Article = require('../models/Article')

module.exports = class Articles extends Backbone.Collection
  model: Article
  url: -> "/stories/#{@storySlug}/articles"
