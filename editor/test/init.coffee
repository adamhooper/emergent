Promise = require('bluebird')

global.sinon = require('sinon')

chai = require('chai')
chai.use(require('chai-as-promised'))
chai.use(require('sinon-chai'))

before ->
  global.app = require('../app')

before (done) ->
  migrator = global.models.sequelize.getMigrator
    path: __dirname + '/../../data-store/migrations'
    filesFilter: /\.coffee$/

  migrator.migrate().complete(done)

beforeEach (done) ->
  tables = [ 'UrlPopularityGet', 'ArticleVersion', 'UrlVersion', 'UrlGet', 'Article', 'Url', 'Story' ]
  truncate = (table) -> global.models[table].destroy({})#, truncate: true)
  Promise.each(tables, truncate).nodeify(done)
