Backbone = require('backbone')
App = require('./app')
StoryApp = require('./apps/stories/StoryApp')

App.on 'start', ->
  if Backbone.history?
    Backbone.history.start()

  if App.getCurrentRoute() == ''
    App.trigger('stories:list')
