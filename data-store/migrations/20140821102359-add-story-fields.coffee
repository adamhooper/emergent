module.exports = 
  up: (migration, DataTypes, done) ->
    migration.addColumn('Story', 'origin', {
      type: DataTypes.STRING
      allowNull: false
      defaultValue: ''
      #comment: 'Who said this first. e.g., a Guardian blog post'
    })
      .then(-> migration.addColumn('Story', 'originUrl', {
        type: DataTypes.STRING
        allowNull: true
        #comment: 'a URL to whatever the origin column mentions'
      }))
      .then(-> migration.addColumn('Story', 'truthiness', {
        type: DataTypes.ENUM
        values: [ 'unknown', 'true', 'false' ]
        allowNull: false
        defaultValue: 'unknown'
        #comment: 'whether or not the claim is objectively true, according to us'
      }))
      .then(-> migration.addColumn('Story', 'truthinessDate', {
        type: DataTypes.DATE
        allowNull: true
        #comment: 'when the world first became aware of the truthiness of the claim'
      }))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('Story', 'origin')
      .then(-> migration.removeColumn('Story', 'originUrl'))
      .then(-> migration.removeColumn('Story', 'truthiness'))
      .then(-> migration.removeColumn('Story', 'truthinessDate'))
      .nodeify(done)
