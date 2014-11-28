models = require('../../data-store').models

models.sequelize.query('''
  SELECT
    s.slug,
    s.truthiness,
    u.url,
    ROW_NUMBER() OVER (PARTITION BY uv."urlId" ORDER BY uv."createdAt") AS "versionNumber",
    uv.source,
    av.stance,
    av."headlineStance",
    uv.body,
    uv.headline
  FROM "Story" s
  INNER JOIN "Article" a ON s.id = a."storyId"
  INNER JOIN "Url" u ON a."urlId" = u.id
  INNER JOIN "ArticleVersion" av ON a.id = av."articleId"
  INNER JOIN "UrlVersion" uv ON av."urlVersionId" = uv.id
  ORDER BY s.slug, u.url, uv."createdAt"
''')
  .then (rows) ->
    process.stdout.write([
      'slug'
      'truthiness'
      'url'
      'versionNumber'
      'source'
      'stance'
      'headlineStance'
      'body'
      'headline'
    ].join(',') + '\r\n')

    quote = (s) ->
      # https://tools.ietf.org/html/rfc4180#section-2
      if /^[\u0020-\u0021\u0023-\u002b\u002d-\u007e]*$/.test(s)
        s
      else
        '"' + s.replace(/"/g, '""') + '"'

    for row in rows
      process.stdout.write([
        quote(row.slug)
        row.truthiness
        quote(row.url)
        row.versionNumber
        quote(row.source)
        row.stance
        row.headlineStance
        quote(row.body)
        quote(row.headline)
      ].join(',') + '\r\n')
