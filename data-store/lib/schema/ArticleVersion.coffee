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

    publishedAt:
      type: Sequelize.DATE
      allowNull: true
      comment: 'publishedAt, according to the URL and our parsers'

    createdAt:
      type: Sequelize.DATE
      allowNull: true
      comment: 'createdAt, from the UrlGet, which is when we actually read stuff'

    # createdBy not necessary: it's always Truthmaker.

    updatedAt:
      type: Sequelize.DATE
      allowNull: false
      comment: 'when an editor set the truthiness'

    updatedBy:
      type: Sequelize.STRING
      allowNull: false
      validate: { isEmail: true }

    truthiness:
      type: Sequelize.ENUM('truth', 'myth', 'claim')
      allowNull: true
      comment: 'Is this text true, as far as this Story is concerned?'

    comment:
      type: Sequelize.TEXT
      allowNull: false # but empty string is okay
      comment: 'The editor may explain his/her reasoning here'
