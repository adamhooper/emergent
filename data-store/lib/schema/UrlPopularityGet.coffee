Sequelize = require('sequelize')

# How many shares did a URL have on Twitter at a given time?
module.exports =
  urlId:
    type: Sequelize.UUID
    allowNull: false
    references: 'Url'
    referencesId: 'id'

  createdAt:
    type: Sequelize.DATE
    allowNull: true
    comment: 'when we received this count'

  # createdBy not necessary: it's always Truthmaker.

  service:
    type: Sequelize.ENUM('facebook', 'twitter', 'google')
    allowNull: false

  rawData:
    type: Sequelize.TEXT
    allowNull: false
    comment: 'body of HTTP response from server'

  shares:
    type: Sequelize.INTEGER
    allowNull: false
    comment: 'number of shares (parsed from rawData)'
