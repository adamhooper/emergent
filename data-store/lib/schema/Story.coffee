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

    published:
      type: Sequelize.BOOLEAN
      allowNull: false
      defaultValue: false
      comment: 'True iff we list this Story in our API index page'

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
      comment: 'Whether or not the claim is objectively true, according to us'

    truthinessDescription:
      type: Sequelize.TEXT
      allowNull: false
      defaultValue: ''
      comment: 'Why we put what we put in the truthiness column'

    truthinessDate:
      type: Sequelize.DATE
      allowNull: true
      comment: 'When the world first became aware of the truthiness of the claim'

    truthinessUrl:
      type: Sequelize.TEXT
      allowNull: true
      validate: { isUrl: true }
      comment: 'A URL to prove whatever the truthiness column mentions'

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
