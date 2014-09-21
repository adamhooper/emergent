before (done) ->
  migrator = global.models.sequelize.getMigrator
    path: __dirname + '/../../data-store/migrations'
    filesFilter: /\.coffee$/

  migrator.migrate().complete(done)

beforeEach ->
  tables = [ 'UrlPopularityGet', 'ArticleVersion', 'UrlVersion', 'UrlGet', 'Article', 'Url', 'Story' ]
  truncate = (table) -> global.models[table].destroy({})#, truncate: true)
  Promise.each(tables, truncate)
