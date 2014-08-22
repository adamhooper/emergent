runQueries = (migration, queries, done) ->
  Promise = migration.migrator.sequelize.Promise
  p = Promise.resolve(null)
  queries.forEach (q) ->
    p = p.then(-> migration.migrator.sequelize.query(q))
  p.nodeify(done)

module.exports = 
  up: (migration, DataTypes, done) ->
    queries = [
      '''CREATE TYPE "Stance" AS ENUM('for', 'against', 'observing', 'ignoring')'''
      '''ALTER TABLE "ArticleVersion" ADD COLUMN stance "Stance" DEFAULT NULL'''
      '''ALTER TABLE "ArticleVersion" ADD COLUMN "headlineStance" "Stance" DEFAULT NULL'''
      '''UPDATE "ArticleVersion" SET stance = (CASE truthiness WHEN 'truth' THEN 'for' WHEN 'myth' THEN 'against' WHEN 'claim' THEN 'observing' ELSE NULL END)::"Stance"'''
      '''UPDATE "ArticleVersion" SET "headlineStance" = (CASE "headlineTruthiness" WHEN 'truth' THEN 'for' WHEN 'myth' THEN 'against' WHEN 'claim' THEN 'observing' ELSE NULL END)::"Stance"'''
      '''ALTER TABLE "ArticleVersion" DROP COLUMN "truthiness"'''
      '''ALTER TABLE "ArticleVersion" DROP COLUMN "headlineTruthiness"'''
      '''DROP TYPE "enum_ArticleVersion_truthiness"'''
      '''DROP TYPE "enum_ArticleVersion_headlineTruthiness"'''
      '''ALTER TYPE "enum_Story_truthiness" RENAME TO "truthiness"'''
    ]

    runQueries(migration, queries, done)

  down: (migration, DataTypes, done) ->
    queries = [
      '''ALTER TYPE "truthiness" RENAME TO "enum_Story_truthiness"'''
      '''CREATE TYPE "enum_ArticleVersion_truthiness" AS ENUM('truth', 'myth', 'claim')'''
      '''CREATE TYPE "enum_ArticleVersion_headlineTruthiness" AS ENUM('truth', 'myth', 'claim')'''
      '''ALTER TABLE "ArticleVersion" ADD COLUMN truthiness "enum_ArticleVersion_truthiness" DEFAULT NULL'''
      '''ALTER TABLE "ArticleVersion" ADD COLUMN "headlineTruthiness" "enum_ArticleVersion_headlineTruthiness" DEFAULT NULL'''
      '''UPDATE "ArticleVersion" SET truthiness = (CASE stance WHEN 'for' THEN 'truth' WHEN 'against' THEN 'myth' WHEN 'observing' THEN 'claim' ELSE NULL END)::"enum_ArticleVersion_truthiness"'''
      '''UPDATE "ArticleVersion" SET "headlineTruthiness" = (CASE stance WHEN 'for' THEN 'truth' WHEN 'against' THEN 'myth' WHEN 'observing' THEN 'claim' ELSE NULL END)::"enum_ArticleVersion_headlineTruthiness"'''
      '''ALTER TABLE "ArticleVersion" DROP COLUMN stance'''
      '''ALTER TABLE "ArticleVersion" DROP COLUMN "headlineStance"'''
      '''DROP TYPE "Stance"'''
    ]

    runQueries(migration, queries, done)
