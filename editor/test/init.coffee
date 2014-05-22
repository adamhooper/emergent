Sails = require('sails/lib/app')

global.sinon = require('sinon')
global.sails = null

chai = require('chai')
chai.use(require('chai-as-promised'))
chai.use(require('sinon-chai'))

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
  , ->
    # sails-mongo will give valid ObjectIDs, but sails-memory won't.
    # Pretend the sails-memory IDs are valid.
    require('../node_modules/sails/node_modules/anchor/index').define('objectid', -> true)
    done()
  )

after (done) ->
  sails = global.sails
  delete global.sails
  sails.lower(done)

beforeEach ->
  Q.all([
    sails.models.article.destroy({})
    sails.models.article_story.destroy({})
    sails.models.story.destroy({})
  ])
