# Usage: coffee $0
#
# This script tries to fill in urlVersion.urlGetId for all cases in which there
# is a UrlGet but the UrlVersion it spawned has urlGetId=null.
#
# Two bits of history here, in bug form:
#
# 1. Back in the day, we used to delete old UrlGets because we fetched way too
#    many of them. (Our last deletions happened sometime in September 2014.)
# 2. Back in the day, we forgot to store UrlVersion.urlGetId, period. (This
#    applied from September 2014 to November 2014.)
#
# This script repairs the damage done by bug 2, staying aware of bug 1.
#
# Without running this script, URL re-parsing (which happens when we update
# a parser version) will not work. Re-parsing tries to match up UrlGets (a
# simpler approach than the one we take here), so if the UrlGets are absent
# it'll insert duplicate UrlVersions.
_ = require('lodash')
Promise = require('bluebird')
process.env.DEBUG = '*'
debug = require('debug')('attach_urlget_ids')

models = require('../../data-store').models
UrlsToReparseFinder = require('../lib/urls_to_reparse_finder')
HtmlParser = require('../lib/parser/html_parser')

urlGetToSha1 = (url, urlGet) ->
  parsed = HtmlParser.parse(url, urlGet.body)
  sha1 = models.UrlVersion.calculateSha1Hex(parsed)
  # May throw an error, if this UrlGet never worked
  sha1

matchUpUrl = (urlId, url) ->
  debug("Starting on URL #{urlId} ...")

  Promise.all([
    models.UrlGet.findAll(where: { urlId: urlId, statusCode: 200 }, order: [ [ 'createdAt' ] ])
    models.UrlVersion.findAll(where: { urlId: urlId, parserVersion: { ne: null } }, order: [ [ 'createdAt' ] ])
  ])
    .spread (urlGets, urlVersions) ->
      debug("Matching #{urlGets.length} UrlGets to #{urlVersions.length} UrlVersions...")

      toUpdate = [] # Array of { urlVersionId, urlGetId }

      # Skip all the UrlVersions for which the urlGetId is NULL because the associated UrlGet was deleted.
      # (We used to delete UrlGets because we had too many so they took up too much space.)
      # Assume the UrlGets were all missing before a certain date and are all present after that date.
      if urlGets.length > 0
        while urlVersions.length > 0 && urlVersions[0].createdAt < urlGets[0].createdAt
          debug("Skipping urlVersion #{urlVersions[0].id} because UrlGet #{urlGets[0].id} came after it")
          urlVersions.shift()

      if urlGets.length > 0 && urlVersions.length > 0
        while urlVersions.length > 0
          urlVersion = urlVersions.shift()

          matched = false
          while urlGets.length > 0 && urlGets[0].createdAt <= urlVersion.createdAt
            urlGet = urlGets.shift()
            sha1 = null
            try
              sha1 = urlGetToSha1(url, urlGet)
            catch
              debug("UrlGet #{urlGet.id} would not parse, so clearly it isn't the one that generated UrlVersion #{urlVersion.id}")
            if sha1 == urlVersion.sha1
              matched = true
              debug("Matched UrlVersion #{urlVersion.id} to UrlGet #{urlGet.id}")
              if !urlVersion.urlGetId?
                toUpdate.push(urlVersionId: urlVersion.id, urlGetId: urlGet.id)
              break

          if !matched
            throw new Error("Could not match UrlVersion #{urlVersion.id} to any UrlGet")
      else
        debug("No matching necessary: there were #{urlGets.length} UrlGets and #{urlVersions.length} UrlVersions")

      if toUpdate.length
        models.sequelize.transaction()
          .then (t) ->
            Promise.map(toUpdate, (row) ->
              models.sequelize.query("""UPDATE "UrlVersion" SET "urlGetId" = '#{row.urlGetId}' WHERE "id" = '#{row.urlVersionId}'""", null, transaction: t)
            , concurrency: 1)
              .then(-> t.commit())
              .then(-> debug("Updated #{toUpdate.length} UrlVersions for Url #{urlId}"))
              .catch (e) ->
                debug("ERROR updating Url #{urlId}", e.stack)
                t.rollback()
                throw e
      else
        debug("No change for Url #{urlId}")

debug('Finding urlIds that have been parsed but are missing UrlGet IDs')
models.sequelize.query('''
  WITH ids AS (
    SELECT DISTINCT "urlId" AS id FROM "UrlVersion" WHERE "parserVersion" IS NOT NULL AND "urlGetId" IS NULL
  )
  SELECT id, url
  FROM "Url"
  WHERE id IN (SELECT id FROM ids)
''')
  .then (rows) ->
    ret = Promise.resolve(null)
    addOne = (row) -> ret = ret.then(-> matchUpUrl(row.id, row.url))
    addOne(row) for row in rows
    ret
  .then(-> debug('DONE'))
  .catch((e) -> debug('ERRORED', e.stack))
  .finally(-> debug('Shutting down'))
