module.exports = 
  up: (migration, DataTypes, done) ->
    migration.changeColumn('Story', 'truthinessDescription', {
      type: DataTypes.TEXT
      allowNull: false
      defaultValue: ''
      #comment: 'Why we put what we put in the truthiness column'
    })
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.changeColumn('Story', 'truthinessDescription', {
      type: DataTypes.STRING
      allowNull: false
      defaultValue: ''
      #comment: 'Why we put what we put in the truthiness column'
    })
      .nodeify(done)
