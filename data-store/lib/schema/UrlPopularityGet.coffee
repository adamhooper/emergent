Sequelize = require('sequelize')

# How many shares did a URL have on Twitter at a given time?
module.exports =
  columns:
    urlId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Url'
      referencesId: 'id'

    createdAt:
      type: Sequelize.DATE
      allowNull: true
      comment: 'when we received this count'

    # createdBy not necessary: it's always Emergent.

    service:
      type: Sequelize.ENUM('facebook', 'twitter', 'google')
      allowNull: false

    shares:
      type: Sequelize.INTEGER
      allowNull: false
      comment: 'number of shares (parsed from HTTP response, which we do not save)'
