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
  # Top-level object tables. CASCADE will wipe the others.
  Tables = [ 'Story', 'Url', 'Category', 'Tag' ]
  Promise.map(Tables, (tableName) ->
    global.models.sequelize.query("""DELETE FROM "#{tableName}" """)
  ).nodeify(done)
