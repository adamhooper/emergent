sails = require('sails/lib/app')

global.app = sails()

before (done) ->
  global.app.lift(
    log:
      level: 'error'

    adapters:
      default: 'memory'

      memory:
        module: 'sails-memory'

    hooks:
      grunt: false
  , done)

after (done) ->
  app.lower(done) if app?
