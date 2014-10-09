Backbone = require('backbone')
Marionette = require('backbone.marionette')

App = new Marionette.Application()

App.addRegions
  mainRegion: '#app'

App.navigate = (route, options) ->
  options ||= {}
  Backbone.history.navigate(route, options)

App.getCurrentRoute = -> Backbone.history.fragment

App.startSubApp = (appName, args) ->
  currentApp = if appName?
    App.module(appName)
  else
    null

  if currentApp != App.currentApp
    App.currentApp?.stop()
    App.currentApp = currentApp
    App.currentApp?.start(args)

module.exports = App
