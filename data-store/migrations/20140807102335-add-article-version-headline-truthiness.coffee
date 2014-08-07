module.exports = 
  up: (migration, DataTypes, done) ->
    migration.addColumn('ArticleVersion', 'headlineTruthiness', {
      type: DataTypes.ENUM
      values: [ 'truth', 'myth', 'claim' ]
      allowNull: true
    })
      .complete(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('ArticleVersion', 'headlineTruthiness')
      .complete(done)
