define [
  'backbone'
  'models/Article'
], (Backbone, Article) ->
  class Articles extends Backbone.Collection
    model: Article
    url: -> "/stories/#{@storySlug}/articles"
