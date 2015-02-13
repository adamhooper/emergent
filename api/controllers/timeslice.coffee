Promise = require('bluebird')
_ = require('lodash')

models = require('../../data-store').models

SLICE_LENGTH = 8 * 3600 * 1000 # 8h

module.exports =
  # Builds up time slices for a given claim.
  #
  # Each slice stores accumulated data on every article.
  #
  # Slices are built backwards from the time of request (or earlier). The first
  # slice probably doesn't contain data on every article.
  'get /claims/:claimId/timeslices': (req, res, next) ->
    Promise.all([
      models.sequelize.query('''
        SELECT
          a.id,
          av.stance,
          av."headlineStance",
          av."createdAt"
        FROM "Article" a
        INNER JOIN "ArticleVersion" av ON a.id = av."articleId"
        WHERE a."storyId" = ?
        ORDER BY av."createdAt"
      ''', null, raw: true, type: 'SELECT', replacements: [ req.params.claimId ])
      models.sequelize.query('''
        SELECT
          a.id,
          p."createdAt",
          p.service,
          p.shares
        FROM "Article" a
        INNER JOIN "UrlPopularityGet" p ON a."urlId" = p."urlId"
        WHERE a."storyId" = ?
        ORDER BY p."createdAt"
      ''', null, raw: true, type: 'SELECT', replacements: [ req.params.claimId ])
    ])
      .spread (articleVersions, popularities) ->
        return [] if !articleVersions.length && !popularities.length

        ownerOfNext = ->
          if !articleVersions.length
            popularities
          else if !popularities.length || articleVersions[0].createdAt < popularities[0].createdAt
            articleVersions
          else
            popularities

        peek = -> ownerOfNext()[0]
        pop = -> ownerOfNext().shift()

        sliceStrings = [] # return value, stringified JSON slices
        data = {} # articleId -> { stance, headlineStance, shares: { facebook, twitter, google } }
        curSliceEnd = (->
          max = peek().createdAt.valueOf() + SLICE_LENGTH
          cur = new Date().valueOf()
          while cur > max
            cur -= SLICE_LENGTH
          cur
        )()

        saveSlice = ->
          sliceStrings.push(JSON.stringify(end: new Date(curSliceEnd), articles: data))
          curSliceEnd += SLICE_LENGTH

        handleOne = ->
          record = pop()
          saveSlice() if record.createdAt.valueOf() > curSliceEnd

          ensureArticle(record)

          if 'shares' of record
            handlePopularity(record)
          else
            handleArticleVersion(record)

        handleAll = ->
          while articleVersions.length > 0 || popularities.length > 0
            handleOne()

        ensureArticle = (record) ->
          if record.id not of data
            data[record.id] =
              stance: null
              headlineStance: null
              shares:
                facebook: null
                twitter: null
                google: null

        handlePopularity = (record) ->
          shares = data[record.id].shares
          shares[record.service] = record.shares

        handleArticleVersion = (record) ->
          version = data[record.id]
          version.stance = record.stance
          version.headlineStance = record.headlineStance

        handleAll()
        saveSlice()
        sliceStrings
      .then (sliceStrings) ->
        res.type('application/json')
        res.header('cache-control', 'public, max-age=300')
        res.send("[#{sliceStrings.join(',')}]")
      .catch(next)
