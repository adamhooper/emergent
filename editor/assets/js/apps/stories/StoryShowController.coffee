App = require('../../app')
Promise = require('bluebird')
Article = require('../../models/Article')
StoryShowLayout = require('../../views/StoryShowLayout')

module.exports =
  go: (slug) ->
    Promise.all([
      App.request('stories/show', slug)
      App.request('story-articles/index', slug)
    ])
      .spread (story, articles) ->
        story.articles = articles
        story
      .then (story) ->
        layout = StoryShowLayout.forStoryInRegion(story, App.mainRegion)

        # TODO are there leaks with `.on` calls?
        layout.on 'articles:new', (data) ->
          story.articles.create(data)

        layout.on 'story:back', ->
          App.trigger('stories:list')

        story.articles.on 'change', (model, options) ->
          if options?.userInput
            model.save()
