DataTypes = require('sequelize').DataTypes

# What we've parsed from a UrlGet.
#
# This is data we'll present to editors so they can determine whether an
# ArticleVersion is true or false.
module.exports =
  urlId:
    type: DataTypes.UUID
    allowNull: false
    references: 'Url'
    referencesId: 'id'
    comment: 'Cached value, so we can read UrlVersions without reading UrlGets'

  urlGetId:
    type: DataTypes.UUID
    allowNull: false
    references: 'UrlGet'
    referencesId: 'id'
    comment: 'The source that we parsed'

  createdAt:
    type: DataTypes.DATE
    allowNull: false

  createdBy:
    type: DataTypes.STRING
    allowNull: true
    validate: { isEmail: true }
    comment: 'null means this was automatically parsed'

  updatedAt:
    type: DataTypes.DATE
    allowNull: false

  updatedBy:
    type: DataTypes.STRING
    allowNull: true
    validate: { isEmail: true }
    comment: 'null means this was automatically parsed and never updated'

  source:
    type: DataTypes.STRING
    allowNull: false
    comment: 'parsed name of the publication at this URL'

  headline:
    type: DataTypes.STRING
    allowNull: false
    comment: 'parsed headline at this URL'

  byline:
    type: DataTypes.STRING
    allowNull: false
    comment: 'parsed comma-separated list of author names at this URL'

  publishedAt:
    type: DataTypes.DATE
    allowNull: false
    comment: 'parsed published/updated date for this URL'

  body:
    type: DataTypes.TEXT
    allowNull: false
    comment: 'parsed body text for this URL'

  sha1:
    type: DataTypes.STRING(20).BINARY
    allowNull: false
    validate: { len: 20 }
    comment: 'SHA-1 digest of "urlId\\0source\\0headline\\0byline\\0publishedAt.toISOString()\0body"'
