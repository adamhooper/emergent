DataTypes = require('sequelize').DataTypes

# How many shares did a URL have on Twitter at a given time?
module.exports =
  urlId:
    type: DataTypes.UUID
    allowNull: false
    references: 'Url'
    referencesId: 'id'

  createdAt:
    type: DataTypes.DATE
    allowNull: true
    comment: 'when we received this count'

  # createdBy not necessary: it's always Truthmaker.

  service:
    type: DataTypes.ENUM('facebook', 'twitter', 'google')
    allowNull: false

  rawData:
    type: DataTypes.TEXT
    allowNull: false
    comment: 'body of HTTP response from server'

  shares:
    type: DataTypes.INTEGER
    allowNull: false
    comment: 'number of shares (parsed from rawData)'
