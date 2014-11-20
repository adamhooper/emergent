Backbone = require('backbone')

module.exports = class ArticleVersion extends Backbone.Model
  defaults:
    stance: null
    headlineStance: null
    comment: ''
    urlVersion:
      source: ''
      headline: ''
      byline: ''
      body: ''
