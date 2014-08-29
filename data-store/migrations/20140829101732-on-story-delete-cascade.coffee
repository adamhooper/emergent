module.exports = 
  up: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    q('''
        ALTER TABLE "Article" DROP CONSTRAINT IF EXISTS "Article_storyId_fkey"
      ''')
      .then(-> q('''
        ALTER TABLE "Article"
        ADD CONSTRAINT "Article_storyId_fkey"
        FOREIGN KEY ("storyId")
        REFERENCES "Story" (id)
        ON DELETE CASCADE
      '''))
      .then(-> q('''
        ALTER TABLE "ArticleVersion"
        DROP CONSTRAINT IF EXISTS "ArticleVersion_articleId_fkey"
      '''))
      .then(-> q('''
        ALTER TABLE "ArticleVersion"
        ADD CONSTRAINT "ArticleVersion_articleId_fkey"
        FOREIGN KEY ("articleId")
        REFERENCES "Article" (id)
        ON DELETE CASCADE
      '''))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    q('''
        ALTER TABLE "Article" DROP CONSTRAINT IF EXISTS "Article_storyId_fkey"
      ''')
      .then(-> q('''
        ALTER TABLE "Article"
        ADD CONSTRAINT "Article_storyId_fkey"
        FOREIGN KEY ("storyId")
        REFERENCES "Story" (id)
      '''))
      .then(-> q('''
        ALTER TABLE "ArticleVersion"
        DROP CONSTRAINT IF EXISTS "ArticleVersion_articleId_fkey"
      '''))
      .then(-> q('''
        ALTER TABLE "ArticleVersion"
        ADD CONSTRAINT "ArticleVersion_articleId_fkey"
        FOREIGN KEY ("articleId")
        REFERENCES "Article" (id)
      '''))
      .nodeify(done)
