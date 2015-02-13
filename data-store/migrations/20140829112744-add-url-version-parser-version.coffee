module.exports = 
  up: (migration, DataTypes, done) ->
    migration.addColumn('UrlVersion', 'parserVersion', {
      type: DataTypes.INTEGER
      allowNull: true
    })
      .then(-> migration.sequelize.query('UPDATE "UrlVersion" SET "parserVersion" = 1 WHERE "createdBy" IS NULL'))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('UrlVersion', 'parserVersion').nodeify(done)
