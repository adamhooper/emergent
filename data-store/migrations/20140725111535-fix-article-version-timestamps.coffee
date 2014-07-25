module.exports = 
  up: (migration, DataTypes, done) ->
    migration.removeColumn('ArticleVersion', 'publishedAt') # it's redundant
      .then -> migration.changeColumn('ArticleVersion', 'createdAt', {
        type: 'TIMESTAMP WITH TIME ZONE' # DataTypes.DATE
        allowNull: false
      })
      .then -> migration.addColumn('ArticleVersion', 'createdBy', {
        type: DataTypes.STRING
        allowNull: true # People can create these manually
      })
      .then -> migration.changeColumn('ArticleVersion', 'updatedBy', {
        type: DataTypes.STRING
        allowNull: true # Because on creation, updatedBy == createdBy
      })
      .complete(done)

  down: (migration, DataTypes, done) ->
    migration.addColumn('ArticleVersion', 'publishedAt', {
      type: 'TIMESTAMP WITH TIME ZONE' # DataTypes.DATE
      allowNull: true
    })
      .then -> migration.migrator.sequelize.query("""UPDATE "ArticleVersion" SET "createdAt" = "updatedAt" WHERE "createdAt" IS NULL""")
      .then -> migration.migrator.sequelize.query('UPDATE "ArticleVersion" SET "publishedAt" = "createdAt"')
      .then -> migration.migrator.sequelize.query("""UPDATE "ArticleVersion" SET "updatedBy" = '[DB migration]' WHERE "updatedBy" IS NULL""")
      .then -> migration.changeColumn('ArticleVersion', 'updatedAt', {
        type: 'TIMESTAMP WITH TIME ZONE' # DataTypes.DATE
        allowNull: false
      })
      .then -> migration.removeColumn('ArticleVersion', 'createdBy')
      .then -> migration.changeColumn('ArticleVersion', 'createdAt', {
        type: 'TIMESTAMP WITH TIME ZONE' # DataTypes.DATE
        allowNull: true
      })
      .complete(done)
