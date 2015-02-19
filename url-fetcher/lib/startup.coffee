_ = require('lodash')
Promise = require('bluebird')
debug = require('debug')('startup')
ms = require('ms')
bold = require('colors/safe').bold

HtmlParser = require('./parser/html_parser')
UrlsToReparseFinder = require('./urls_to_reparse_finder')
UrlReparser = require('./url_reparser')
models = require('../../data-store/lib/models')

Services = [ 'fetch', 'facebook', 'twitter', 'google' ]
FetchDelayInMs = 2 * 3600 * 1000 # 2hrs

# Pushes all URLs to the queue.
#
# Be sure to empty out the queue beforehand!
module.exports = class Startup
  # Arguments:
  #
  # * `articles` a Mongo `Collection`
  # * `urls` a Mongo `Collection`
  # * `queue` a `Queue`
  constructor: (options) ->
    throw 'Must pass queues, an Object mapping service name to UrlTaskQueue' if !options.queues
    throw 'Must pass taskTimeChooser, a TaskTimeChooser' if !options.taskTimeChooser
    @queues = options.queues
    @taskTimeChooser = options.taskTimeChooser

  refreshCachedShareCounts: (done) ->
    models.sequelize.query('''
      WITH data AS (
        SELECT
          "urlId",
          service,
          MAX(shares) AS "nShares"
        FROM "UrlPopularityGet"
        GROUP BY "urlId", service
      )
      UPDATE "Url"
      SET
        "cachedNSharesFacebook" = COALESCE((SELECT "nShares" FROM data WHERE service = 'facebook' AND "urlId" = id), 0),
        "cachedNSharesGoogle" = COALESCE((SELECT "nShares" FROM data WHERE service = 'google' AND "urlId" = id), 0),
        "cachedNSharesTwitter" = COALESCE((SELECT "nShares" FROM data WHERE service = 'twitter' AND "urlId" = id), 0)
    ''')
      .nodeify(done)

  addAllUrlsToQueues: (done) ->
    serviceAndIdToNextDate = {} # service -> url id -> { at, nPreviousFetches }

    models.sequelize.query('''
      SELECT
        'fetch' AS service,
        COALESCE(ug."urlId", uv."urlId") AS id,
        LEAST(MIN(uv."createdAt"), MIN(ug."createdAt")) AS "firstDate",
        GREATEST(MAX(uv."createdAt"), MAX(ug."createdAt")) AS "lastDate"
      FROM "UrlVersion" uv
      FULL JOIN "UrlGet" ug ON uv."urlId" = ug."urlId"
      GROUP BY ug."urlId", uv."urlId"

      UNION

      SELECT
        service::varchar AS service,
        "urlId" AS id,
        MIN("createdAt") AS "firstDate",
        MAX("createdAt") AS "lastDate"
      FROM "UrlPopularityGet"
      GROUP BY "urlId", service
    ''', null, type: 'SELECT')
      .then (rows) =>
        now = new Date().valueOf()
        for row in rows
          nPreviousFetches = @taskTimeChooser.guessNPreviousInvocations(row.firstDate, row.lastDate)
          nextDate = @taskTimeChooser.chooseTime(nPreviousFetches, row.lastDate)
          debug('did %s %s %s and %s ago; get #%s is in %s',
            row.service,
            row.id,
            bold(ms(now - row.firstDate)),
            bold(ms(now - row.lastDate)),
            bold(nPreviousFetches + 1)
            bold("#{ms(nextDate - now)}")
          )
          serviceAndIdToNextDate[row.service] ?= {}
          serviceAndIdToNextDate[row.service][row.id] =
            at: nextDate
            nPreviousFetches: nPreviousFetches
        null
      .then -> models.Url.findAllRaw()
      .then (urls) =>
        now = new Date().valueOf()
        debug("Queueing #{urls.length} URLs...")
        for url in urls
          for service in Services
            nextDate = if url.id not of serviceAndIdToNextDate[service]
              # It's a new URL; fetch it ASAP
              at: 0
              nPreviousFetches: 0
            else
              serviceAndIdToNextDate[service][url.id]

            if nextDate.at?
              debug("queue #{bold(service)} ##{(nextDate.nPreviousFetches ? 0) + 1} for URL #{bold(url.id)} in #{bold(ms(nextDate.at - now))}")
              @queues[service].queue
                urlId: url.id
                url: url.url
                at: nextDate.at
                nPreviousFetches: nextDate.nPreviousFetches
            else
              debug("do not queue #{service} for URL #{url.id}")
      .nodeify(done)

  runNewParsers: (done) ->
    finder = new UrlsToReparseFinder(htmlParser: HtmlParser)
    reparser = new UrlReparser(htmlParser: HtmlParser)

    find = Promise.promisify(finder.findUrlsToReparse, finder)
    reparse = Promise.promisify(reparser.reparse, reparser)

    debug("Looking for URLs that need re-parsing...")
    find()
      .map(((url) ->
        debug("Reparsing URL #{url.id}: #{url.url}...")
        reparse(url.id, url.url)
          .then(null)
          .catch (e) ->
            debug(e.stack)
            debug("Failed reparse: #{e.message}. Skipping....")
      ), concurrency: 1)
      .nodeify(done)

  run: (done) ->
    debug("Recalculating URL share counts...")
    @refreshCachedShareCounts (err) =>
      return done(err) if err?
      debug("Queueing URLs...")
      @addAllUrlsToQueues (err) =>
        return done(err) if err?
        debug("Spawning re-parsing handler in the background...")
        @runNewParsers (err) ->
          return done(err) if err?
          debug("Finished running new parsers.")
          done(null)
