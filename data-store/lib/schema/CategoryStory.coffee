Sequelize = require('sequelize')

module.exports =
  columns:
    categoryId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Category'
      referencesId: 'id'
      unique: 'categoryId_storyId'

    storyId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Story'
      referencesId: 'id'
      unique: 'categoryId_storyId'

    createdAt:
      type: Sequelize.DATE
      allowNull: false

    createdBy:
      type: Sequelize.STRING
      allowNull: false
      validate: { isEmail: true }
