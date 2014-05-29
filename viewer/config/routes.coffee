go = (spec) ->
  [ controllerName, actionName ] = spec.split('#')
  controller = require("../controllers/#{controllerName}")
  controller[actionName]

module.exports = (app) ->
  app.get('/', go('Welcome#show'))
  app.get('/popularity', go('Popularity#index'))
  #app.get('/popularity/:storyId', go('Popularity#show'))
