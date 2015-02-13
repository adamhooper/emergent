module.exports = 
  up: (migration, DataTypes, done) ->
    migration.changeColumn('UrlVersion', 'urlGetId', {
      type: DataTypes.UUID
      allowNull: true
    }).complete(done)

  down: (migration, DataTypes, done) ->
    migration.sequelize.query('''DELETE FROM "ArticleVersion" WHERE "urlVersionId" IN (SELECT id FROM "UrlVersion" WHERE "urlGetId" IS NULL)''')
      .then -> migration.sequelize.query('''DELETE FROM "UrlVersion" WHERE "urlGetId" IS NULL''')
      .then -> migration.changeColumn('UrlVersion', 'urlGetId', {
        type: DataTypes.UUID
        allowNull: false
      })
      .complete(done)
