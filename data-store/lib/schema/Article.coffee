Sequelize = require('sequelize')

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
  columns:
    storyId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Story'
      referencesId: 'id'
      unique: 'storyId_urlId'

    urlId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Url'
      referencesId: 'id'
      unique: 'storyId_urlId'

    createdAt:
      type: Sequelize.DATE
      allowNull: false

    createdBy:
      type: Sequelize.STRING
      allowNull: false
      validate: { isEmail: true }

  classMethods:
    findAllWithUnseenVersion: (options={}, queryOptions={}) ->
      options = _.extend({
        where: '''
          id IN (
            SELECT DISTINCT "articleId"
            FROM "ArticleVersion"
            WHERE "headlineStance" IS NULL OR "stance" IS NULL
          )
          '''
        order: [[ 'storyId' ]]
      }, options)
      @findAll(options, queryOptions)
