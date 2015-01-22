module.exports =
  up: (migration, DataTypes, done) ->
    migration.migrator.sequelize.query('CREATE EXTENSION pgcrypto')
      .then ->
        # It used to be:
        #                     CONVERT_TO(source, 'utf-8')
        #    || E'\\\\x00' || CONVERT_TO(headline, 'utf-8')
        #    || E'\\\\x00' || CONVERT_TO(byline, 'utf-8')
        #    || E'\\\\x00' || CONVERT_TO(TO_CHAR("publishedAt", 'IYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), 'utf-8')
        #    || E'\\\\x00' || CONVERT_TO(body, 'utf-8')
        #
        # ... but we don't want publishedAt any more
        #
        # Oh, and the "\\\\" ends up being a single "\" by the time it makes it
        # to Postgres: the String CoffeeScript parses has "\\", and the string
        # Postgres parses has "\".
        migration.migrator.sequelize.query('''
          UPDATE "UrlVersion"
          SET sha1 =
            DIGEST(
                              CONVERT_TO(source, 'utf-8')
             || E'\\\\x00' || CONVERT_TO(headline, 'utf-8')
             || E'\\\\x00' || CONVERT_TO(byline, 'utf-8')
             || E'\\\\x00' || CONVERT_TO(body, 'utf-8')
            , 'sha1');
        ''')
      .then -> migration.removeColumn('UrlVersion', 'publishedAt')
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    throw new Error("This migration cannot be undone: the publishedAt data is gone forever, and the system wouldn't work if we set it to NULL.")
