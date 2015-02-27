sequelize = require('../../data-store').models.sequelize

Columns = [
  [ 's.id', 'claimId' ]
  [ 's.slug', 'claimSlug' ]
  [ 's.headline', 'claimHeadline' ]
  [ 's.truthiness', 'claimTruthiness' ]
  [ 'a.id', 'articleId' ]
  [ 'u.url', 'articleUrl' ]
  [ 'ROW_NUMBER() OVER (PARTITION BY av."articleId" ORDER BY av."createdAt")', 'articleVersion' ]
  [ 'av.id', 'articleVersionId' ]
  [ 'uv.headline', 'articleHeadline' ]
  [ 'uv.byline', 'articleByline' ]
  [ 'av.stance', 'articleStance' ]
  [ 'av."headlineStance"', 'articleHeadlineStance' ]
  [ 'uv.body', 'articleBody' ]
]

Query = """
  SELECT #{Columns.map((c) -> "#{c[0]} AS \"#{c[1]}\"").join(', ')}
  FROM "Story" s
  INNER JOIN "Article" a ON s.id = a."storyId"
  INNER JOIN "Url" u ON a."urlId" = u.id
  INNER JOIN "ArticleVersion" av ON a.id = av."articleId"
  INNER JOIN "UrlVersion" uv ON av."urlVersionId" = uv.id
  ORDER BY s.slug, u.url, av."createdAt"
"""

quote = (s) ->
  # https://tools.ietf.org/html/rfc4180#section-2
  if /^[\u0020-\u0021\u0023-\u002b\u002d-\u007e]*$/.test(s)
    s
  else
    '"' + s.replace(/"/g, '""') + '"'

printRow = (row) ->
  values = Columns.map((c) -> row[c[1]])
  process.stdout.write(values.join(',') + '\r\n')

process.stdout.write(Columns.map((c) -> c[1]).join(',') + '\r\n')
sequelize.connectionManager.connect(sequelize.options)
  .tap (connection) ->
    result = connection.query(Query)
    result.on('row', printRow)
    result.on('end', -> connection.end())
