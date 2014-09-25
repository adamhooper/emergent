before (done) ->
  migrator = global.models.sequelize.getMigrator
    path: __dirname + '/../../data-store/migrations'
    filesFilter: /\.coffee$/

  migrator.migrate().complete(done)

beforeEach ->
  p = Promise.resolve(null)

  truncate = (table) ->
    p = p.then(-> models[table].destroy({}))#, truncate: true)

  for table in [ 'UrlPopularityGet', 'ArticleVersion', 'UrlVersion', 'UrlGet', 'Article', 'Url', 'Story' ]
    truncate(table)

  p
