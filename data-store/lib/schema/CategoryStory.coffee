Sequelize = require('sequelize')

module.exports =
  columns:
    id: null

    categoryId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Category'
      referencesId: 'id'
      unique: 'categoryId_storyId'
      primaryKey: true

    storyId:
      type: Sequelize.UUID
      allowNull: false
      references: 'Story'
      referencesId: 'id'
      unique: 'categoryId_storyId'
      primaryKey: true

    createdAt:
      type: Sequelize.DATE
      allowNull: false

    createdBy:
      type: Sequelize.STRING
      allowNull: false
      validate: { isEmail: true }
