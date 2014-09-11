_ = require('lodash')

models = require('../../data-store').models

articleToJson = (row) ->
  ret =
    id: row.id
    url: row.url

  ret.lastVersion = if row.articleVersionId?
    articleVersionId: row.articleVersionId
    headline: row.headline
    byline: row.byline
    source: row.source
    publishedAt: row.publishedAt?.toISOString()
    createdAt: row.createdAt.toISOString()
  else
    null

  ret

module.exports =
  'get /claims/:claimId/articles': (req, res, next) ->
    models.sequelize.query('''
      WITH
      "rankedArticleVersion" AS (
        SELECT id, "articleId", "urlVersionId", "createdAt", stance, "headlineStance", RANK() OVER (PARTITION BY "articleId" ORDER BY "createdAt" DESC) AS rank
        FROM "ArticleVersion"
      )
      SELECT
        a.id,
        u.url,
        av.id AS "articleVersionId",
        uv.headline AS headline,
        uv.byline AS byline,
        uv.source AS source,
        uv."publishedAt" AS "publishedAt",
        uv."createdAt" AS "createdAt"
      FROM "Article" a
      INNER JOIN "Url" u ON a."urlId" = u.id
      LEFT JOIN "rankedArticleVersion" av ON a.id = av."articleId" AND av.rank = 1
      LEFT JOIN "UrlVersion" uv ON av."urlVersionId" = uv.id
      WHERE a."storyId" = ?
    ''', null, null, [ req.params.claimId ])
      .then((json) -> res.json(json))
      .catch(next)
