allTestFiles = []
TEST_REGEXP = /Spec\.js$/

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
    marionette: 'bower_components/marionette/lib/core/amd/backbone.marionette'
    q: 'bower_components/q/q'
    underscore: 'bower_components/underscore/underscore'

  callback: ->
    require [
      'bower_components/chai/chai'
      'bower_components/sinon/lib/sinon'
      'bower_components/chai-jquery/chai-jquery'
      'bower_components/sinon-chai/lib/sinon-chai'
      #'bower_components/chai-as-promised/lib/chai-as-promised'
    ], (chai, sinon, chaiJquery, sinonChai) ->
      chai.use(chaiJquery)
      chai.use(sinonChai)
      #chai.use(chaiAsPromised)
      window.sinon = sinon
      window.expect = chai.expect
      window.__karma__.start()
