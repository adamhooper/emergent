Promise = require('sequelize').Promise

# [ tableName, columnName, allowNull ] list of varchar columns
COLUMNS = [
  [ 'Story', 'description', false ]
  [ 'Story', 'headline', false ]
  [ 'Story', 'origin', false ]
  [ 'Story', 'originUrl', true ]
  [ 'Story', 'slug', false ]
  [ 'Url', 'url', false ]
  [ 'UrlVersion', 'byline', false ]
  [ 'UrlVersion', 'headline', false ]
  [ 'UrlVersion', 'source', false ]
]

changeColumns = (migration, toType) ->
  changeColumn = (tableName, columnName, allowNull) ->
    migration.changeColumn(tableName, columnName, {
      type: toType
      allowNull: allowNull
    })

  Promise.resolve(COLUMNS)
    .map(((list) -> changeColumn(list...)), concurrency: 1)

module.exports = 
  up: (migration, DataTypes, done) ->
    changeColumns(migration, DataTypes.TEXT)
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    changeColumns(migration, DataTypes.STRING)
      .nodeify(done)
