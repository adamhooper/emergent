Sequelize = require('sequelize')

# A Story: something you heard on the Internet.
#
# Is it true? Is it false?
#
# We track that via Articles: one per URL.
module.exports =
  columns:
    slug:
      type: Sequelize.TEXT
      allowNull: false
      unique: true
      comment: 'Unique identifier for building URLs that use this story'

    headline:
      type: Sequelize.TEXT
      allowNull: false
      comment: 'The one-line bit of text we show the user'

    description:
      type: Sequelize.TEXT
      allowNull: false
      comment: 'The two-line bit of text we show the user'

    origin:
      type: Sequelize.TEXT
      allowNull: false
      defaultValue: ''
      comment: 'Who said this first. e.g., a Guardian blog post'

    originUrl:
      type: Sequelize.TEXT
      allowNull: true
      validate: { isUrl: true }
      comment: 'a URL to whatever the origin column mentions'

    truthiness:
      type: Sequelize.ENUM
      values: [ 'unknown', 'true', 'false' ]
      defaultValue: 'unknown'
      allowNull: false
      comment: 'whether or not the claim is objectively true, according to us'

    truthinessDate:
      type: Sequelize.DATE
      allowNull: true
      comment: 'when the world first became aware of the truthiness of the claim'

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
