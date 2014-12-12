Promise = require('bluebird')
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
    'categories'
    'tags'
  ])

getCategories = (claimIds) ->
  sqlClaimIds = claimIds.map((id) -> "'#{id}'::uuid").join(',')
  q = """
    SELECT
      cs."storyId" AS "claimId",
      c.name
    FROM "CategoryStory" cs
    INNER JOIN "Category" c ON cs."categoryId" = c.id
    WHERE cs."storyId" IN (#{sqlClaimIds})
    ORDER BY cs."storyId", c.name
  """
  models.sequelize.query(q, null, raw: true)
    .then (rows) ->
      ret = {}
      (ret[claimId] = []) for claimId in claimIds
      for row in rows
        ret[row.claimId].push(row.name)
      ret

getTags = (claimIds) ->
  sqlClaimIds = claimIds.map((id) -> "'#{id}'::uuid").join(',')
  q = """
    SELECT
      st."storyId" AS "claimId",
      t.name
    FROM "StoryTag" st
    INNER JOIN "Tag" t ON st."tagId" = t.id
    WHERE st."storyId" IN (#{sqlClaimIds})
    ORDER BY st."storyId", t.name
  """
  models.sequelize.query(q, null, raw: true)
    .then (rows) ->
      ret = {}
      (ret[claimId] = []) for claimId in claimIds
      for row in rows
        ret[row.claimId].push(row.name)
      ret

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
        if claims.length
          claimIds = (c.id for c in claims)
          Promise.all([
            getShareCounts(claimIds)
            getCategories(claimIds)
            getTags(claimIds)
          ])
            .spread (counts, categories, tags) ->
              for claim in claims
                claim.nShares = counts[claim.id]
                claim.categories = categories[claim.id]
                claim.tags = tags[claim.id]
              null
        else
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
          throw new Error('Claim not found')
      .tap (claim) ->
        # WARNING: .nShares and .categories aren't unit-tested here!
        Promise.all([
          getShareCounts([claim.id])
          getCategories([claim.id])
          getTags([claim.id])
        ])
          .spread (counts, categories, tags) ->
            claim.nShares = counts[claim.id]
            claim.categories = categories[claim.id]
            claim.tags = tags[claim.id]
            null
      .then(claimToJson)
      .then (json) ->
        res.header('cache-control', 'public, max-age=300')
        res.json(json)
      .catch(next)
