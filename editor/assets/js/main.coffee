require.config
  baseUrl: 'js'

  shim:
    diff_match_patch:
      exports: 'diff_match_patch'

  paths:
    backbone: 'bower_components/backbone/backbone'
    'backbone.babysitter': 'bower_components/backbone.babysitter/lib/backbone.babysitter'
    'backbone.wreqr': 'bower_components/backbone.wreqr/lib/backbone.wreqr'
    jquery: 'bower_components/jquery/dist/jquery'
    marionette: 'bower_components/marionette/lib/core/amd/backbone.marionette'
    moment: 'bower_components/moment/moment'
    diff_match_patch: 'vendor/diff_match_patch_uncompressed'
    q: 'bower_components/q/q'
    underscore: 'bower_components/underscore/underscore'

require [ 'app' ], (App) ->
  App.start()
