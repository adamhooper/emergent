Sequelize = require('sequelize')

# How true is an Article at a given time?
module.exports =
  columns:
    articleId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Article'
      referencesId: 'id'

    urlVersionId:
      type: Sequelize.UUID
      allowNull: false
      references: 'UrlVersion'
      referencesId: 'id'

    createdAt:
      type: Sequelize.DATE
      allowNull: false

    createdBy:
      type: Sequelize.STRING
      allowNull: true # NULL means Truthmaker created it automatically
      validate: { isEmail: true }

    updatedAt:
      type: Sequelize.DATE
      allowNull: false
      comment: 'when an editor set the truthiness'

    updatedBy:
      type: Sequelize.STRING
      allowNull: true # NULL means Truthmaker created it automatically
      validate: { isEmail: true }

    stance:
      type: Sequelize.ENUM
      values: ['for', 'against', 'observing', 'ignoring']
      allowNull: true
      comment: 'Does the body support the claim?'

    headlineStance:
      type: Sequelize.ENUM
      values: ['for', 'against', 'observing', 'ignoring']
      allowNull: true
      comment: 'Does the headline support the claim?'

    comment:
      type: Sequelize.TEXT
      allowNull: false # but empty string is okay
      defaultValue: ''
      comment: 'The editor may explain his/her reasoning here'
