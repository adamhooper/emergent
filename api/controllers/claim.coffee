_ = require('lodash')

models = require('../../data-store').models

claimToJson = (claim) ->
  _.pick(claim, [
    'id'
    'slug'
    'headline'
    'description'
    'origin'
    'originUrl'
    'nShares'
    'truthiness'
    'truthinessDate'
    'truthinessDescription'
    'truthinessUrl'
    'createdAt'
  ])

getShareCounts = (claimIds) ->
  sqlClaimIds = claimIds.map((id) -> "('#{id}'::uuid)")
  q = """
    WITH
    "ClaimIds" AS (
      SELECT id
      FROM (VALUES#{sqlClaimIds}) AS t(id)
    ),
    "UrlIds" AS (
      SELECT "urlId" AS id
      FROM "Article"
      WHERE "storyId" IN (SELECT id FROM "ClaimIds")
    ),
    "UrlMaxes" AS (
      SELECT "urlId", service, MAX("shares") AS "nShares"
      FROM "UrlPopularityGet"
      WHERE "urlId" IN (SELECT id FROM "UrlIds")
      GROUP BY "urlId", service
    )
    SELECT a."storyId" AS "claimId", SUM(m."nShares") AS "nShares"
    FROM "Article" a
    INNER JOIN "UrlMaxes" m
            ON a."urlId" = m."urlId"
    WHERE a."storyId" IN (SELECT id FROM "ClaimIds")
    GROUP BY a."storyId"
  """
  models.sequelize.query(q, null, raw: true)
    .then (rows) ->
      ret = {}
      # Set defaults
      (ret[claimId] = 0) for claimId in claimIds
      for row in rows
        ret[row.claimId] = parseInt(row.nShares, 10)
      ret

getShareCount = (claimId) ->
  getShareCounts([claimId])
    .then((hash) -> hash[claimId] || 0)

module.exports =
  'get /claims': (req, res, next) ->
    models.Story.findAll(where: { published: true })
      .tap (claims) ->
        getShareCounts(claims.map((c) -> c.id))
          .tap (counts) ->
            (c.nShares = counts[c.id]) for c in claims
            null
      .then((claims) -> { claims: claims.map(claimToJson) })
      .then (json) ->
        res.header('cache-control', 'public, max-age=300')
        res.json(json)
      .catch(next)

  'get /claims/:id': (req, res, next) ->
    models.Story.find(req.params.id)
      .tap (claim) ->
        if !claim?
          res.status(404)
          throw new Error("Claim not found")
      .tap (claim) ->
        getShareCounts([claim.id]).then((count) -> claim.nShares = count)
      .then(claimToJson)
      .then (json) ->
        res.header('cache-control', 'public, max-age=300')
        res.json(json)
      .catch(next)
