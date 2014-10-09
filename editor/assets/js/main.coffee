$ = require('jquery')
Backbone = require('backbone')
Backbone.$ = $

App = require('./app')

require('./startup')

$ ->
  App.start()
