Sequelize = require('sequelize')
crypto = require('crypto')

rowToSha1 = (row) ->
  s = [
    row.source
    row.headline
    row.byline
    row.publishedAt.toISOString()
    row.body
  ].join('\u0000')
  hash = crypto.createHash('sha1')
  hash.update(s, 'utf-8')
  hash.digest()

# What we've parsed from a UrlGet.
#
# This is data we'll present to editors so they can determine whether an
# ArticleVersion is true or false.
module.exports =
  columns:
    urlId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Url'
      referencesId: 'id'
      comment: 'Cached value, so we can read UrlVersions without reading UrlGets'

    urlGetId:
      type: Sequelize.UUID
      allowNull: true
      references: 'UrlGet'
      referencesId: 'id'
      comment: 'The source that we parsed'

    createdAt:
      type: Sequelize.DATE
      allowNull: false

    createdBy:
      type: Sequelize.STRING
      allowNull: true
      validate: { isEmail: true }
      comment: 'null means this was automatically parsed'

    updatedAt:
      type: Sequelize.DATE
      allowNull: false

    updatedBy:
      type: Sequelize.STRING
      allowNull: true
      validate: { isEmail: true }
      comment: 'null means this was automatically parsed and never updated'

    source:
      type: Sequelize.STRING
      allowNull: false
      comment: 'parsed name of the publication at this URL'

    headline:
      type: Sequelize.STRING
      allowNull: false
      comment: 'parsed headline at this URL'

    byline:
      type: Sequelize.STRING
      allowNull: false
      comment: 'parsed comma-separated list of author names at this URL'

    publishedAt:
      type: Sequelize.DATE
      allowNull: false
      comment: 'parsed published/updated date for this URL'

    body:
      type: Sequelize.TEXT
      allowNull: false
      comment: 'parsed body text for this URL'

    sha1:
      type: Sequelize.STRING.BINARY
      allowNull: false
      comment: 'SHA-1 digest of "source\\0headline\\0byline\\0publishedAt.toISOString()\0body"'
      get: -> @getDataValue('sha1')?.toString('hex') || null
      set: (v) -> v && @setDataValue('sha1', new Buffer(v, 'hex')) || null

    parserVersion:
      type: Sequelize.INTEGER
      allowNull: false
      comment: 'parser that generated the parsed values'

  classMethods:
    calculateSha1Hex: (attributes) ->
      rowToSha1(attributes).toString('hex')

  hooks:
    beforeValidate: (row) ->
      sha1 = rowToSha1(row)
      row.setDataValue('sha1', sha1)
      Sequelize.Promise.resolve(row)
