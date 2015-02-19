Promise = require('sequelize').Promise

Services = [ 'Facebook', 'Google', 'Twitter' ]

module.exports =
  up: (migration, DataTypes, done) ->
    Promise.resolve(Services)
      .each (service) ->
        migration.addColumn 'Url', "cachedNShares#{service}",
          type: DataTypes.BIGINT # The Gangnam style data type! https://plus.google.com/+youtube/posts/BUXfdWqu86Q
          allowNull: false
          defaultValue: 0
      .each (service) ->
        migration.changeColumn 'Url', "cachedNShares#{service}",
          type: DataTypes.BIGINT
          allowNull: false
      .complete(done)

  down: (migration, DataTypes, done) ->
    Promise.resolve(Services)
      .each((service) -> migration.removeColumn('Url', "cachedNShares#{service}"))
      .complete(done)
