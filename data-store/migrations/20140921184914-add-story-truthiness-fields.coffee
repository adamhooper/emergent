module.exports = 
  up: (migration, DataTypes, done) ->
    migration.addColumn('Story', 'truthinessDescription', {
      type: DataTypes.STRING
      allowNull: false
      defaultValue: ''
      #comment: 'Why we put what we put in the truthiness column'
    })
      .then(-> migration.addColumn('Story', 'truthinessUrl', {
          type: DataTypes.STRING
          allowNull: true
          #comment: 'A URL to prove whatever the truthiness column mentions'
      }))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('Story', 'truthinessUrl')
      .then(-> migration.removeColumn('Story', 'truthinessDescription'))
      .nodeify(done)
