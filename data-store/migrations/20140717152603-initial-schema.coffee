Promise = require('sequelize').Promise

# Remember, this is a _migration_, not our official schema. The sum of
# migrations should bring us to what's at lib/schema/*.coffee. Comments belong
# there, not here.
initialSchema = (DataTypes) -> [
  {
    name: 'Story'
    columns:
        id:
          type: DataTypes.UUID
          allowNull: false
          primaryKey: true
          defaultValue: DataTypes.UUIDV1

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
  }
  {
    name: 'Url'
    columns:
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

      url:
        type: DataTypes.STRING
        allowNull: false
        validate: { isUrl: true }
  }
  {
    name: 'Article'
    columns:
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

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
  }
  {
    name: 'UrlGet'
    columns:
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

      urlId:
        type: DataTypes.UUID
        allowNull: false
        references: 'Url'
        referencesId: 'id'

      createdAt:
        type: DataTypes.DATE
        allowNull: false
        defaultValue: DataTypes.NOW

      statusCode:
        type: DataTypes.INTEGER
        allowNull: false

      responseHeaders:
        type: DataTypes.TEXT
        allowNull: false

      body:
        type: DataTypes.TEXT
        allowNull: false
  }
  {
    name: 'UrlVersion'
    columns:
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

      urlId:
        type: DataTypes.UUID
        allowNull: false
        references: 'Url'
        referencesId: 'id'
        comment: 'Cached value, so we can read UrlVersions without reading UrlGets'

      urlGetId:
        type: DataTypes.UUID
        allowNull: false
        references: 'UrlGet'
        referencesId: 'id'
        comment: 'The source that we parsed'

      createdAt:
        type: DataTypes.DATE
        allowNull: false

      createdBy:
        type: DataTypes.STRING
        allowNull: true
        validate: { isEmail: true }
        comment: 'null means this was automatically parsed'

      updatedAt:
        type: DataTypes.DATE
        allowNull: false

      updatedBy:
        type: DataTypes.STRING
        allowNull: true
        validate: { isEmail: true }
        comment: 'null means this was automatically parsed and never updated'

      source:
        type: DataTypes.STRING
        allowNull: false
        comment: 'parsed name of the publication at this URL'

      headline:
        type: DataTypes.STRING
        allowNull: false
        comment: 'parsed headline at this URL'

      byline:
        type: DataTypes.STRING
        allowNull: false
        comment: 'parsed comma-separated list of author names at this URL'

      publishedAt:
        type: DataTypes.DATE
        allowNull: false
        comment: 'parsed published/updated date for this URL'

      body:
        type: DataTypes.TEXT
        allowNull: false
        comment: 'parsed body text for this URL'

      sha1:
        type: 'BYTEA'
        allowNull: false
        validate: { len: 20 }
        comment: 'SHA-1 digest of source\\0headline\\0byline\\0publishedAt.toISOString()\\0body'
  }
  {
    name: 'ArticleVersion'
    columns:
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

      articleId:
        type: DataTypes.UUID
        allowNull: false
        references: 'Article'
        referencesId: 'id'

      urlVersionId:
        type: DataTypes.UUID
        allowNull: false
        references: 'UrlVersion'
        referencesId: 'id'

      publishedAt:
        type: DataTypes.DATE
        allowNull: true
        comment: 'publishedAt, according to the URL and our parsers'

      createdAt:
        type: DataTypes.DATE
        allowNull: true
        comment: 'createdAt, from the UrlGet, which is when we actually read stuff'

      updatedAt:
        type: DataTypes.DATE
        allowNull: false
        comment: 'when an editor set the truthiness'

      updatedBy:
        type: DataTypes.STRING
        allowNull: false
        validate: { isEmail: true }

      truthiness:
        type: DataTypes.ENUM
        values: [ 'truth', 'myth', 'claim' ]
        allowNull: true
        comment: 'Is this text true, as far as this Story is concerned?'

      comment:
        type: DataTypes.TEXT
        allowNull: false
        comment: 'The editor may explain his/her reasoning here'
  }
  {
    name: 'UrlPopularityGet'
    columns:
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

      urlId:
        type: DataTypes.UUID
        allowNull: false
        references: 'Url'
        referencesId: 'id'

      createdAt:
        type: DataTypes.DATE
        allowNull: true
        comment: 'when we received this count'

      service:
        type: DataTypes.ENUM
        values: [ 'facebook', 'twitter', 'google' ]
        allowNull: false

      rawData:
        type: DataTypes.TEXT
        allowNull: false
        comment: 'body of HTTP response from server'

      shares:
        type: DataTypes.INTEGER
        allowNull: false
        comment: 'number of shares (parsed from rawData)'
  }
]

module.exports =
  up: (migration, DataTypes, done) ->
    schema = initialSchema(DataTypes)

    indices = [
      [ 'Story', 'slug' ]
      [ 'Url', 'url' ]
      [ 'Article', 'storyId' ]
      [ 'Article', 'urlId' ]
      [ 'UrlGet', 'urlId' ]
      [ 'UrlVersion', 'urlId' ]
      [ 'UrlVersion', 'urlGetId' ]
      [ 'ArticleVersion', 'articleId' ]
      [ 'ArticleVersion', 'urlVersionId' ]
      [ 'UrlPopularityGet', 'urlId' ]
    ]

    buildSchemaItem = (item) -> migration.createTable(item.name, item.columns)
    buildIndex = (item) -> migration.addIndex(item[0], [item[1]])

    Promise.each(schema, buildSchemaItem)
      .then(-> Promise.each(indices, buildIndex))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    schema = initialSchema(DataTypes).reverse()

    unbuildSchemaItem = (item) ->
      migration.dropTable(item.name)

    Promise.each(schema, unbuildSchemaItem).nodeify(done)
