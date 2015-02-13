module.exports =
  up: (migration, DataTypes, done) ->
    migration.removeColumn('UrlPopularityGet', 'rawData')
      .nodeify(done)
  down: (migration, DataTypes, done) ->
    migration.addColumn('UrlPopularityGet', 'rawData', {
      type: DataTypes.STRING
      allowNull: false
      defaultValue: '{}'
    })
      .then(-> migration.sequelize.query('''ALTER TABLE "UrlPopularityGet" ALTER "rawData" DROP DEFAULT'''))
      .nodeify(done)
