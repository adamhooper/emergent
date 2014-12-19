module.exports = 
  up: (migration, DataTypes, done) ->
    migration.addColumn('Story', 'publishedAt', {
      type: DataTypes.DATE
      allowNull: true
    })
      .then -> migration.migrator.sequelize.query('UPDATE "Story" SET "publishedAt" = "createdAt" WHERE published = TRUE')
      .then -> migration.removeColumn('Story', 'published')
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.adddColumn('Story', 'published', {
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
    })
      .then -> migration.migrator.sequelize.query('UPDATE "Story" SET published = ("publishedAt" IS NOT NULL)')
      .then -> migration.removeColumn('Story', 'publishedAt')
      .nodeify(done)
