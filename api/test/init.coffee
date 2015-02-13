before ->
  require('../../data-store').migrate()

beforeEach (done) ->
  # Top-level object tables. CASCADE will wipe the others.
  Tables = [ 'Story', 'UserSubmittedClaim', 'Url', 'Category', 'Tag' ]
  Promise.map(Tables, (tableName) ->
    global.models.sequelize.query("""DELETE FROM "#{tableName}" """)
  ).nodeify(done)
