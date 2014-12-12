module.exports = 
  up: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    q(           '''ALTER TABLE "Category" ADD COLUMN slug VARCHAR''')
      .then -> q('''UPDATE "Category" SET slug = REGEXP_REPLACE(LOWER(REPLACE(name, '.', '')), '[^a-z0-9]+', '-')''')
      .then -> q('''ALTER TABLE "Category" ALTER slug SET NOT NULL''')
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.removeColumn('Category', 'slug').nodeify(done)
