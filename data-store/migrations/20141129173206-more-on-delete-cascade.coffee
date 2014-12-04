module.exports = 
  up: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    q('''
        ALTER TABLE "Article" DROP CONSTRAINT IF EXISTS "Article_urlId_fkey"
    ''')
      .then(-> q('''
        ALTER TABLE "Article"
        ADD CONSTRAINT "Article_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
        ON DELETE CASCADE
      '''))
      .then(-> q('''
        ALTER TABLE "UrlVersion" DROP CONSTRAINT IF EXISTS "UrlVersion_urlId_fkey"
      '''))
      .then(-> q('''
        ALTER TABLE "UrlVersion"
        ADD CONSTRAINT "UrlVersion_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
        ON DELETE CASCADE
      '''))
      .then(-> q('''
        ALTER TABLE "UrlGet" DROP CONSTRAINT IF EXISTS "UrlGet_urlId_fkey"
      '''))
      .then(-> q('''
        ALTER TABLE "UrlGet"
        ADD CONSTRAINT "UrlGet_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
        ON DELETE CASCADE
      '''))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    q('''
        ALTER TABLE "Article" DROP CONSTRAINT IF EXISTS "Article_urlId_fkey"
    ''')
      .then(-> q('''
        ALTER TABLE "Article"
        ADD CONSTRAINT "Article_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
      '''))
      .then(-> q('''
        ALTER TABLE "UrlVersion" DROP CONSTRAINT IF EXISTS "UrlVersion_urlId_fkey"
      '''))
      .then(-> q('''
        ALTER TABLE "UrlVersion"
        ADD CONSTRAINT "UrlVersion_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
      '''))
      .then(-> q('''
        ALTER TABLE "UrlGet" DROP CONSTRAINT IF EXISTS "UrlGet_urlId_fkey"
      '''))
      .then(-> q('''
        ALTER TABLE "UrlGet"
        ADD CONSTRAINT "UrlGet_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
        ON DELETE CASCADE
      '''))
      .nodeify(done)
