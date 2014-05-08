define [ 'app', 'api/stories', 'api/articles' ], (App, StoriesApi, ArticlesApi) ->
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
      list: ->
        require [ 'apps/stories/StoryListController' ], (StoryListController) ->
          executeAction(StoryListController.go, null)

      show: (slug) ->
        require [ 'apps/stories/StoryShowController' ], (StoryShowController) ->
          executeAction(StoryShowController.go, slug)

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
