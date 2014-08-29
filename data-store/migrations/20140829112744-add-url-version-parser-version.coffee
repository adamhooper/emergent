module.exports = 
  up: (migration, DataTypes, done) ->
    migration.addColumn('UrlVersion', 'parserVersion', {
      type: DataTypes.INTEGER
      allowNull: false
      defaultValue: 1
    })
      .then(-> migration.migrator.sequelize.query('ALTER TABLE "UrlVersion" ALTER COLUMN "parserVersion" DROP DEFAULT'))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('UrlVersion', 'parserVersion').nodeify(done)
