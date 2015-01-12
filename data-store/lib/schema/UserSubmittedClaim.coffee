Sequelize = require('sequelize')

# Something a random Internet denizen heard and cares about.
#
# This serves a few purposes:
#
# * Convinces our users we value their feedback, building trust
# * Provides claim ideas that our users care about
# * Lets us track URLs sooner
module.exports =
  columns:
    createdAt:
      type: Sequelize.DATE
      allowNull: false
      comment: 'When the user sent the claim'

    requestIp:
      type: 'INET'
      allowNull: false
      comment: 'Where the request came from'

    claim:
      type: Sequelize.STRING(1024)
      allowNull: false
      comment: 'Proposed claim'

    url:
      type: Sequelize.STRING(1024)
      allowNull: false
      comment: 'Proposed URL'

    spam:
      type: Sequelize.BOOLEAN
      allowNull: false
      comment: 'True if an editor says this is spam'

    archived:
      type: Sequelize.BOOLEAN
      allowNull: false
      comment: 'True if an editor no longer wishes to see this claim'

    urlId:
      type: Sequelize.UUID
      allowNull: true
      comment: 'If set, we are tracking this URL'
