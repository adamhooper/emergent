define [
  'app'
  'apps/stories/StoryApp'
], (App, StoryApp) ->
  App.on 'initialize:after', ->
    if Backbone.history?
      Backbone.history.start()

    if App.getCurrentRoute() == ''
      App.trigger('stories:list')
