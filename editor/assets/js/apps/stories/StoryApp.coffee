App = require('../../app')
StoriesApi = require('../../api/stories')
ArticlesApi = require('../../api/articles')
StoryListController = require('./StoryListController')
StoryShowController = require('./StoryShowController')

App.module 'StoryApp', (StoryApp, App, Backbone, Marionette, $, _) ->
  StoryApp.startWithParent = false

App.module 'Routers.StoryApp', (StoryAppRouter, App, Backbone, Marionette, $, _) ->
  class StoryAppRouter.Router extends Marionette.AppRouter
    appRoutes:
      'stories': 'list'
      'stories/:slug': 'show'

  executeAction = (action, arg) ->
    App.startSubApp('StoryApp')
    action(arg)
    App.execute('set:active:header', 'stories')

  API =
    list: -> executeAction(StoryListController.go, null)

    show: (slug) -> executeAction(StoryShowController.go, slug)

  App.on 'stories:list', ->
    App.navigate('stories')
    API.list()

  App.on 'stories:show', (slug) ->
    App.navigate("stories/#{slug}")
    API.show(slug)

  App.addInitializer ->
    StoriesApi.installToReqres(App.reqres)
    ArticlesApi.installToReqres(App.reqres)
    new StoryAppRouter.Router(controller: API)
