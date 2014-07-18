Sequelize = require('sequelize')

# A Story: something you heard on the Internet.
#
# Is it true? Is it false?
#
# We track that via Articles: one per URL.
module.exports =
  columns:
    slug:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      comment: 'Unique identifier for building URLs that use this story'

    headline:
      type: Sequelize.STRING
      allowNull: false
      comment: 'The one-line bit of text we show the user'

    description:
      type: Sequelize.STRING
      allowNull: false
      comment: 'The two-line bit of text we show the user'

    createdAt:
      type: Sequelize.DATE
      allowNull: false

    createdBy:
      type: Sequelize.STRING
      allowNull: false
      validate: { isEmail: true }

    updatedAt:
      type: Sequelize.DATE
      allowNull: false

    updatedBy:
      type: Sequelize.STRING
      allowNull: false
      validate: { isEmail: true }
