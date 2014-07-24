Sails = require('sails/lib/app')
Promise = require('bluebird')

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

before (done) ->
  migrator = global.models.sequelize.getMigrator
    path: __dirname + '/../../data-store/migrations'
    filesFilter: /\.coffee$/
  migrator.migrate().done(done)

beforeEach (done) ->
  tables = [ 'UrlPopularityGet', 'ArticleVersion', 'UrlVersion', 'UrlGet', 'Article', 'Url', 'Story' ]
  truncate = (table) -> global.models[table].destroy({}, truncate: true)
  Promise.each(tables, truncate).nodeify(done)
