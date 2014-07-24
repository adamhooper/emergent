Promise = require('sequelize').Promise

module.exports =
  up: (migration, DataTypes, done) ->
    migration.removeIndex('Url', [ 'url' ])
      .then -> migration.addIndex('Url', [ 'url' ], indicesType: 'UNIQUE')
      .then -> migration.addIndex('Article', [ 'storyId', 'urlId' ], indicesType: 'UNIQUE')
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.removeIndex('Article', [ 'storyId', 'urlId' ])
      .then -> migration.removeIndex('Url', [ 'url' ])
      .then -> migration.addIndex('Url', [ 'url' ])
