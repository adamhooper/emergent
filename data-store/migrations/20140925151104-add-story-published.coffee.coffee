module.exports = 
  up: (migration, DataTypes, done) ->
    migration.addColumn('Story', 'published', {
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
      #comment: 'True iff we list this Story in our API index page'
    })
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('Story', 'published')
      .nodeify(done)
