DataTypes = require('sequelize').DataTypes

# How true is an Article at a given time?
module.exports =
  articleId:
    type: DataTypes.UUID
    allowNull: false
    references: 'Article'
    referencesId: 'id'

  urlVersionId:
    type: DataTypes.UUID
    allowNull: false
    references: 'UrlVersion'
    referencesId: 'id'

  publishedAt:
    type: DataTypes.DATE
    allowNull: true
    comment: 'publishedAt, according to the URL and our parsers'

  createdAt:
    type: DataTypes.DATE
    allowNull: true
    comment: 'createdAt, from the UrlGet, which is when we actually read stuff'

  # createdBy not necessary: it's always Truthmaker.

  updatedAt:
    type: DataTypes.DATE
    allowNull: false
    comment: 'when an editor set the truthiness'

  updatedBy:
    type: DataTypes.STRING
    allowNull: false
    validate: { isEmail: true }

  truthiness:
    type: DataTypes.ENUM('truth', 'myth', 'claim')
    allowNull: true
    comment: 'Is this text true, as far as this Story is concerned?'

  comment:
    type: DataTypes.TEXT
    allowNull: false # but empty string is okay
    comment: 'The editor may explain his/her reasoning here'
