module.exports = 
  up: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    q('''
        ALTER TABLE "UrlPopularityGet" DROP CONSTRAINT IF EXISTS "UrlPopularityGet_urlId_fkey"
    ''')
      .then(-> q('''
        ALTER TABLE "UrlPopularityGet"
        ADD CONSTRAINT "UrlPopularityGet_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
        ON DELETE CASCADE
      '''))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    q('''
        ALTER TABLE "UrlPopularityGet" DROP CONSTRAINT IF EXISTS "UrlPopularityGet_urlId_fkey"
    ''')
      .then(-> q('''
        ALTER TABLE "UrlPopularityGet"
        ADD CONSTRAINT "UrlPopularityGet_urlId_fkey"
        FOREIGN KEY ("urlId")
        REFERENCES "Url" (id)
      '''))
      .nodeify(done)
