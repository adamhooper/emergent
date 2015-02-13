Tables = [
  [ 'Category', 'CategoryStory', 'Category', 'categoryId', 'Story', 'storyId' ]
  [ 'Tag', 'StoryTag', 'Story', 'storyId', 'Tag', 'tagId' ]
]

module.exports = 
  up: (migration, DataTypes, done) ->
    Promise = migration.sequelize.Promise
    Promise.map(Tables, (arr) ->
      [ tableName, joinTableName, joinTable1, joinColumn1, joinTable2, joinColumn2 ] = arr
      migration.sequelize.query("""
        CREATE TABLE "#{tableName}" (
          id UUID NOT NULL,
          name VARCHAR NOT NULL,
          PRIMARY KEY (id),
          UNIQUE (name)
        )
      """)
        .then -> migration.sequelize.query("""
          CREATE TABLE "#{joinTableName}" (
            "#{joinColumn1}" UUID NOT NULL REFERENCES "#{joinTable1}" (id) ON DELETE CASCADE,
            "#{joinColumn2}" UUID NOT NULL REFERENCES "#{joinTable2}" (id) ON DELETE CASCADE,
            "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL,
            "createdBy" VARCHAR NOT NULL,
            PRIMARY KEY ("#{joinColumn1}", "#{joinColumn2}")
          )
        """)
        .then -> migration.sequelize.query("""
          CREATE INDEX ON "#{joinTableName}" ("#{joinColumn2}")
        """)
    ).nodeify(done)

  down: (migration, DataTypes, done) ->
    Promise = migration.sequelize.Promise
    Promise.map(Tables, (arr) ->
      [ tableName, joinTableName, joinTable1, joinColumn1, joinTable2, joinColumn2 ] = arr
      migration.sequelize.query("""DROP TABLE "#{joinTableName}" """)
        .then -> migration.sequelize.query("""DROP TABLE "#{tableName}" """)
    )
      .nodeify(done)
