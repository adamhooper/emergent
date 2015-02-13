Promise = require('bluebird')
validator = require('validator')
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
    'publishedAt'
    'categories'
    'tags'
    'stances'
    'createdAt'
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
  models.sequelize.query(q, null, raw: true, type: 'SELECT')
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
  models.sequelize.query(q, null, raw: true, type: 'SELECT')
    .then (rows) ->
      ret = {}
      (ret[claimId] = []) for claimId in claimIds
      for row in rows
        ret[row.claimId].push(row.name)
      ret

getStanceCounts = (claimIds) ->
  sqlClaimIds = claimIds.map((id) -> "('#{id}'::uuid)").join(',')
  q = """
    WITH
    "ClaimIds" AS (
      SELECT id
      FROM (VALUES#{sqlClaimIds}) AS t(id)
    ),
    "ArticleIds" AS (
      SELECT id
      FROM "Article"
      WHERE "storyId" IN (SELECT id FROM "ClaimIds")
    ),
    "RankedArticleVersions" AS (
      SELECT
        id,
        "articleId",
        stance,
        RANK() OVER (PARTITION BY "articleId" ORDER BY "createdAt" DESC) AS rank
      FROM "ArticleVersion"
      WHERE "articleId" IN (SELECT id FROM "ArticleIds")
    )
    SELECT
      a."storyId" as "claimId",
      av.stance,
      COUNT(*) AS "n"
    FROM "RankedArticleVersions" av
    INNER JOIN "Article" a ON av."articleId" = a.id
    WHERE av.rank = 1
    GROUP BY "claimId", stance
  """
  models.sequelize.query(q, null, raw: true, type: 'SELECT')
    .then (rows) ->
      ret = {}
      # Set defaults
      (ret[claimId] = {}) for claimId in claimIds
      for row in rows
        ret[row.claimId][row.stance] = +row.n
      ret

getShareCounts = (claimIds) ->
  sqlClaimIds = claimIds.map((id) -> "('#{id}'::uuid)").join(',')
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
    SELECT
      a."storyId" AS "claimId",
      SUM(m."nShares") AS "nShares"
    FROM "Article" a
    INNER JOIN "UrlMaxes" m
            ON a."urlId" = m."urlId"
    WHERE a."storyId" IN (SELECT id FROM "ClaimIds")
    GROUP BY a."storyId"
  """
  models.sequelize.query(q, null, raw: true, type: 'SELECT')
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
    models.Story.findAll(where: { publishedAt: { lte: new Date() } }, order: [[ 'publishedAt', 'DESC' ]])
      .tap (claims) ->
        if claims.length
          claimIds = (c.id for c in claims)
          Promise.all([
            getShareCounts(claimIds)
            getStanceCounts(claimIds)
            getCategories(claimIds)
            getTags(claimIds)
          ])
            .spread (counts, stances, categories, tags) ->
              for claim in claims
                claim.nShares = counts[claim.id]
                claim.stances = stances[claim.id]
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

  'options /claims': (req, res, next) ->
    res.header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    res.header('Access-Control-Allow-Headers', 'Content-Type')
    res.status(204).end()

  'post /claims': (req, res, next) ->
    attributes =
      requestIp: req.ip
      claim: (req.body.claim || '').trim()
      url: (req.body.url || '').trim()
      urlId: null
      spam: false
      archived: false

    if !validator.isLength(attributes.claim, 3, 1024)
      return res.status(400).send(message: 'You must pass a "claim" attribute with length between 3 and 1024 characters')
    if !validator.isURL(attributes.url, protocols: [ 'http', 'https' ], require_protocol: true)
      return res.status(400).send(message: 'You must pass a "url" attribute with a valid URL')

    models.Url.find(where: { url: attributes.url })
      .tap((urlObject) -> attributes.urlId = urlObject.id if urlObject)
      .then(-> models.UserSubmittedClaim.create(attributes, null))
      .then((usc) -> res.status(201).json(usc.toJSON()))
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
