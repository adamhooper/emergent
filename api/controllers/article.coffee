_ = require('lodash')
Promise = require('bluebird')

models = require('../../data-store').models
MultiPointCurve = require('../lib/multi_point_curve')
MaxDate = new Date(8640000000000000)

class ShareCurve
  constructor: (popularities) ->
    points = ([ p.createdAt.valueOf(), p.shares ] for p in popularities)
    @curve = new MultiPointCurve(points)

  _toNumber: (d) ->
    if d?
      new Date(d).valueOf()
    else
      null

  atOrBefore: (date) ->
    x = @_toNumber(date)
    p = @curve.xyAtOrBefore(x)
    if x? && p?
      { shares: p[1], date: new Date(p[0]) }
    else
      { shares: 0, date: null }

  atOrAfter: (date) ->
    x = @_toNumber(date)
    p = @curve.xyAtOrAfter(x)
    if x? && p?
      { shares: p[1], date: new Date(p[0]) }
    else
      { shares: null, date: null }

  guessAt: (date) ->
    x = @_toNumber(date)
    y = @curve.yAt(x)
    if x? && y?
      { shares: Math.round(y), date: new Date(date) }
    else
      { shares: null, date: new Date(date) }

# Accepts UrlPopularityGets.
# Returns { facebook: MultiPointCurve(date, shares), ... }
popularitiesToShareCurves = (popularities) ->
  ret = {}
  for service, ps of _.groupBy(popularities, 'service')
    ret[service] = new ShareCurve(ps)
  ret

articleToJson = (row) ->
  ret =
    id: row.id
    url: row.url

  ret.lastVersion = if row.articleVersionId?
    articleVersionId: row.articleVersionId
    headline: row.headline
    byline: row.byline
    source: row.source
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
        uv."createdAt" AS "createdAt"
      FROM "Article" a
      INNER JOIN "Url" u ON a."urlId" = u.id
      LEFT JOIN "rankedArticleVersion" av ON a.id = av."articleId" AND av.rank = 1
      LEFT JOIN "UrlVersion" uv ON av."urlVersionId" = uv.id
      WHERE a."storyId" = ?
    ''', null, null, [ req.params.claimId ])
      .then((json) -> res.json(json))
      .catch(next)

  'get /articles/:articleId/stances-over-time': (req, res, next) ->
    models.Article.find(id: req.params.articleId)
      .tap (article) ->
        if !article?
          res.status(404)
          throw new Error('Article not found')
      .then (article) ->
        Promise.all([
          article
          models.ArticleVersion.findAll(where: { articleId: article.id }, order: [[ 'createdAt' ]])
          models.UrlVersion.findAll(where: { urlId: article.urlId }, order: [[ 'createdAt' ]])
          models.UrlPopularityGet.findAll(where: { urlId: article.urlId }, order: [[ 'createdAt' ]])
        ])
      .spread (article, versions, urlVersions, popularities) ->
        slices = []
        lastStance = undefined # null != undefined
        lastHeadlineStance = undefined # null != undefined
        nextSlice = undefined

        if versions.length != urlVersions.length
          throw new Error("Somehow, versions.length is #{versions.length} and urlVersions.length is #{urlVersions.length}. They must be equal.")

        for version in versions
          urlVersion = urlVersions.shift()

          if version.stance != nextSlice?.stance || version.headlineStance != nextSlice?.headlineStance
            # Change of stance! Write the last one if it exists
            if nextSlice?
              if (ms = urlVersion.millisecondsSincePreviousUrlGet)?
                nextSlice.endDate.min = new Date(Math.max(
                  nextSlice.endDate.min?.valueOf(),
                  version.createdAt - ms
                ))
              slices.push(nextSlice)

            nextSlice =
              articleVersionIds: []
              stance: version.stance
              headlineStance: version.headlineStance
              comment: version.comment # the first one is usually the one we want
              startTime: version.createdAt
              endDate:
                min: null
                max: null
                guess: null

          # Whether or not we're on a new stance, mark that we've seen this version
          nextSlice.articleVersionIds.push(version.id)
          nextSlice.endDate.min = version.createdAt # always a lower bound

        # Done. Let's jot down our last stance....
        slices.push(nextSlice) if nextSlice?

        # Set endDate.max, endDate.guess
        if slices.length > 0
          for i in [0...(slices.length-1)]
            endDate = slices[i].endDate
            endDate.max = slices[i + 1].startTime
            endDate.guess = new Date((endDate.min.valueOf() + endDate.max.valueOf()) / 2)

        # Set endShares
        shareCurves = popularitiesToShareCurves(popularities)
        for slice in slices
          endDate = slice.endDate
          slice.endShares = endShares = { min: {}, max: {}, guess: {} }
          for service, curve of shareCurves
            endShares.min[service] = curve.atOrBefore(endDate.min)
            endShares.max[service] = curve.atOrAfter(endDate.max)
            if endDate.guess?
              endShares.guess[service] = curve.guessAt(endDate.guess)
            else
              endShares.guess[service] = curve.atOrBefore(MaxDate)
              endShares.guess[service].date = null

        slices
      .then (json) ->
        res.header('cache-control', 'public, max-age=300')
        res.json(json)
      .catch(next)
