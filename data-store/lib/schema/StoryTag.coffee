Sequelize = require('sequelize')

module.exports =
  columns:
    id: null

    storyId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Story'
      referencesId: 'id'
      unique: 'storyId_tagId'

    tagId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Tag'
      referencesId: 'id'
      unique: 'storyId_tagId'

    createdAt:
      type: Sequelize.DATE
      allowNull: false

    createdBy:
      type: Sequelize.STRING
      allowNull: false
      validate: { isEmail: true }
