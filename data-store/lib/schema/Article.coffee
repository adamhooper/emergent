DataTypes = require('sequelize').DataTypes

# How a URL relates to a Story.
#
# An Article is a glorified many-to-many relation. Each Story appears at many
# URLs, and (less importantly) any given URL may relate to multiple Stories.
#
# An Article represents the _subjective_ relation between a Url and a Story:
#
# * Its existence proves an editor thinks a Url applies to a Story.
# * The editor will deem, for each UrlVersion, whether it is true or false.
#   (Editors do this in ArticleVersions.)
module.exports =
  storyId:
    type: DataTypes.UUID
    allowNull: false
    references: 'Story'
    referencesId: 'id'

  urlId:
    type: DataTypes.UUID
    allowNull: false
    references: 'Url'
    referencesId: 'id'

  createdAt:
    type: DataTypes.DATE
    allowNull: false

  createdBy:
    type: DataTypes.STRING
    allowNull: false
    validate: { isEmail: true }
