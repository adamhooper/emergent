Backbone = require('backbone')
App = require('./app')

require('./apps/stories/StoryApp')
require('./apps/stories/UnseenArticleApp')

App.on 'start', ->
  if Backbone.history?
    Backbone.history.start()

  if App.getCurrentRoute() == ''
    App.trigger('stories:list')
