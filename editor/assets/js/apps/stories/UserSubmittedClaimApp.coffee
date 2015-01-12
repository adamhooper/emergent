App = require('../../app')
UserSubmittedClaimController = require('./UserSubmittedClaimController')

App.module 'UserSubmittedClaimApp', (UserSubmittedClaimApp, App, Backbone, Marionette, $, _) ->
  UserSubmittedClaimApp.startWithParent = false

App.module 'Routers.UserSubmittedClaimApp', (UserSubmittedClaimAppRouter, App, Backbone, Marionette, $, _) ->
  class UserSubmittedClaimAppRouter.Router extends Marionette.AppRouter
    appRoutes:
      'user-submitted-claims': 'list'

  API =
    list: ->
      App.startSubApp('UserSubmittedClaimApp')
      UserSubmittedClaimController.go()
      App.execute('set:active:header', 'user-submitted-claims')

  App.on 'user-submitted-claims:list', ->
    console.log('HERE')
    App.navigate('user-submitted-claims')
    API.list()

  App.addInitializer ->
    new UserSubmittedClaimAppRouter.Router(controller: API)
