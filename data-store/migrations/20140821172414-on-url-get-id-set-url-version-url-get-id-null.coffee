module.exports = 
  up: (migration, DataTypes, done) ->
    migration.sequelize.query('''ALTER TABLE "UrlVersion" DROP CONSTRAINT IF EXISTS "UrlVersion_urlGetId_fkey"''')
      .then(-> migration.sequelize.query('''
        ALTER TABLE "UrlVersion"
          ADD CONSTRAINT "UrlVersion_urlGetId_fkey"
          FOREIGN KEY ("urlGetId")
          REFERENCES "UrlGet"(id)
          ON DELETE SET NULL
      '''))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.sequelize.query('''ALTER TABLE "UrlVersion" DROP CONSTRAINT IF EXISTS "UrlVersion_urlGetId_fkey"''')
      .then(-> migration.sequelize.query('''
        ALTER TABLE "UrlVersion"
          ADD CONSTRAINT "UrlVersion_urlGetId_fkey"
          FOREIGN KEY ("urlGetId")
          REFERENCES "UrlGet"(id)
      '''))
      .nodeify(done)
