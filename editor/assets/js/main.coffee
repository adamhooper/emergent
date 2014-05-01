require.config
  baseUrl: 'js'
  paths:
    backbone: 'bower_components/backbone/backbone'
    'backbone.babysitter': 'bower_components/backbone.babysitter/lib/backbone.babysitter'
    'backbone.wreqr': 'bower_components/backbone.wreqr/lib/backbone.wreqr'
    jquery: 'bower_components/jquery/dist/jquery'
    marionette: 'bower_components/marionette/lib/backbone.marionette'
    underscore: 'bower_components/underscore/underscore'

require [ 'app' ], (App) ->
  new App()
