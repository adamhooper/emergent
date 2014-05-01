allTestFiles = []
TEST_REGEXP = /(spec|test)\.js$/i

for file, __ of window.__karma__.files
  if TEST_REGEXP.test(file)
    allTestFiles.push(file)

require.config
  baseUrl: '/base/assets/js'
  deps: allTestFiles

  # Copied from ../assets/js/main.coffee
  paths:
    backbone: 'bower_components/backbone/backbone'
    'backbone.babysitter': 'bower_components/backbone.babysitter/lib/backbone.babysitter'
    'backbone.wreqr': 'bower_components/backbone.wreqr/lib/backbone.wreqr'
    jquery: 'bower_components/jquery/dist/jquery'
    marionette: 'bower_components/marionette/lib/backbone.marionette'
    underscore: 'bower_components/underscore/underscore'

  callback: window.__karma__.start
