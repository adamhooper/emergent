Sails = require('sails/lib/app')

global.sails = null

before (done) ->
  global.sails = Sails()
  global.sails.lift(
    port: 1338

    log:
      level: 'error'

    connections:
      default: 'main'

      main:
        adapter: 'sails-memory'

    hooks:
      grunt: false

    express:
      customMiddleware: (app) ->
        global.app = app

        # Circumvent passport by adding a user to each request
        app.use (req, res, next) ->
          req.user =
            email: 'user@example.org'
          next()
  , done)

after (done) ->
  sails = global.sails
  delete global.sails
  sails.lower(done)
