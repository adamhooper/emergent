Promise = require('bluebird')

global.sinon = require('sinon')

chai = require('chai')
chai.use(require('chai-as-promised'))
chai.use(require('sinon-chai'))

before ->
  global.app = require('../app')

before ->
  require('../../data-store').migrate()

beforeEach ->
  # Top-level object tables. CASCADE will wipe the others.
  #
  # Delete them sequentially: if we do it all at once, we sometimes deadlock.
  p = Promise.resolve(null)
  [ 'Story', 'UserSubmittedClaim', 'Url', 'Category', 'Tag' ].forEach (tableName) ->
    p = p.tap(-> global.models.sequelize.query("""DELETE FROM "#{tableName}" """))
  p
