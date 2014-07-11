DataTypes = require('sequelize').DataTypes

# A Story: something you heard on the Internet.
#
# Is it true? Is it false?
#
# We track that via Articles: one per URL.
module.exports =
  slug:
    type: DataTypes.STRING
    allowNull: false
    unique: true
    comment: 'Unique identifier for building URLs that use this story'

  headline:
    type: DataTypes.STRING
    allowNull: false
    comment: 'The one-line bit of text we show the user'

  description:
    type: DataTypes.STRING
    allowNull: false
    comment: 'The two-line bit of text we show the user'

  createdAt:
    type: DataTypes.DATE
    allowNull: false

  createdBy:
    type: DataTypes.STRING
    allowNull: false
    validate: { isEmail: true }

  updatedAt:
    type: DataTypes.DATE
    allowNull: false

  updatedBy:
    type: DataTypes.STRING
    allowNull: false
    validate: { isEmail: true }
