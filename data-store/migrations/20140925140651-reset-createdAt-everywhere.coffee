module.exports = 
  up: (migration, DataTypes, done) ->
    q = (s) -> migration.sequelize.query(s)

    q('''
        WITH x AS (SELECT "storyId", MIN("createdAt") FROM "Article" GROUP BY "storyId")
        UPDATE "Story" s
        SET "createdAt" = (SELECT "createdAt" from x WHERE x."storyId" = s.id)
        WHERE EXISTS (SELECT 1 FROM x WHERE "storyId" = s.id)
      ''')
      .then(-> q('''
        UPDATE "UrlVersion" uv
        SET "createdAt" = (SELECT "createdAt" FROM "UrlGet" ug WHERE ug.id = uv."urlGetId")
        WHERE "urlGetId" IS NOT NULL;
      '''))
      .then(-> q('''
        UPDATE "ArticleVersion" av
        SET "createdAt" = (SELECT "createdAt" FROM "UrlVersion" uv WHERE uv.id = av."urlVersionId")
      '''))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    # The old data is wrong, and it has no value.
    done()
