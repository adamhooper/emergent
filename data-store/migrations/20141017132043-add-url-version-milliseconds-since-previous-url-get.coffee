module.exports =
  up: (migration, DataTypes, done) ->
    sequelize = migration.sequelize
    q = sequelize.query.bind(sequelize)

    migration.addColumn('UrlVersion', 'millisecondsSincePreviousUrlGet', DataTypes.BIGINT)
      .then(-> q("""
        WITH gets AS (
          SELECT "id", "urlId", "createdAt", ROW_NUMBER() OVER (PARTITION BY "urlId" ORDER BY "createdAt") AS "r"
          FROM "UrlGet"
        ), get_intervals AS (
          SELECT g2.id, EXTRACT(EPOCH FROM (g2."createdAt" - g1."createdAt")) * 1000 AS "ms"
          FROM gets g2
          INNER JOIN gets g1
             ON g1."urlId" = g2."urlId"
            AND g2.r = g1.r + 1
        )
        UPDATE "UrlVersion" uv
        SET "millisecondsSincePreviousUrlGet" = (SELECT ms FROM "get_intervals" gi WHERE gi.id = uv."urlGetId")
      """)) # Derive "millisecondsSincePreviousUrlGet" where possible
      .then(-> q("""
        UPDATE "UrlVersion" uv
        SET "millisecondsSincePreviousUrlGet" = 7200000
        WHERE "urlGetId" IS NULL
          AND "millisecondsSincePreviousUrlGet" IS NULL
          AND EXISTS (SELECT 1 FROM "UrlVersion" uv2 WHERE uv."urlId" = uv2."urlId" AND uv."createdAt" > uv2."createdAt")
      """)) # Assume 2hrs when we know there was an interval but we've deleted the UrlGet because it was too old
      .complete(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('UrlVersion', 'millisecondsSincePreviousUrlGet')
      .complete(done)
