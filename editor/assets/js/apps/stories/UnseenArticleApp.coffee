App = require('../../app')
UnseenArticlesApi = require('../../api/unseen-articles')
UnseenArticleListController = require('./UnseenArticleListController')

App.module 'UnseenArticleApp', (UnseenArticleApp, App, Backbone, Marionette, $, _) ->
  UnseenArticleApp.startWithParent = false

App.module 'Routers.UnseenArticleApp', (UnseenArticleAppRouter, App, Backbone, Marionette, $, _) ->
  class UnseenArticleAppRouter.Router extends Marionette.AppRouter
    appRoutes:
      'unseen': 'list'

  executeAction = (action, arg) ->
    App.startSubApp('UnseenArticleApp')
    action(arg)
    App.execute('set:active:header', 'unseen')

  API =
    list: -> executeAction(UnseenArticleListController.go, null)

  App.on 'unseen:list', ->
    App.navigate('unseen')
    API.list()

  App.addInitializer ->
    UnseenArticlesApi.installToReqres(App.reqres)
    new UnseenArticleAppRouter.Router(controller: API)
