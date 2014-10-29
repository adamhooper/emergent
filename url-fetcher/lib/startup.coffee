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

  addAllUrlsToQueues: (done) ->
    serviceAndIdToNextDate = {} # service -> url id -> { at, nPreviousFetches }

    models.sequelize.query("""
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
    """)
      .then (rows) =>
        now = new Date().valueOf()
        for row in rows
          nPreviousFetches = @taskTimeChooser.guessNPreviousInvocations(row.firstDate, row.lastDate)
          nextDate = @taskTimeChooser.chooseTime(nPreviousFetches, row.lastDate)
          debug('%s handler fetched %s %s and %s, worth %s gets; next is in %s',
            row.service,
            row.id,
            bold("#{ms(now - row.firstDate)} ago"),
            bold("#{ms(now - row.lastDate)} ago"),
            bold(nPreviousFetches)
            bold("#{ms(nextDate - now)}")
          )
          serviceAndIdToNextDate[row.service] ?= {}
          serviceAndIdToNextDate[row.service][row.id] =
            at: nextDate
            nPreviousFetches: nPreviousFetches
        null
      .then -> models.Url.findAllRaw()
      .then (urls) =>
        debug('URLS', urls)
        for url in urls
          for service in Services
            nextDate = if url.id not of serviceAndIdToNextDate[service]
              # It's a new URL; fetch it ASAP
              at: 0
              nPreviousFetches: 0
            else
              serviceAndIdToNextDate[service][url.id]

            debug(url.url, service, nextDate)

            if nextDate.at?
              @queues[service].queue
                urlId: url.id
                url: url.url
                at: nextDate.at
                nPreviousFetches: nextDate.nPreviousFetches
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
    @runNewParsers (err) =>
      return done(err) if err
      @addAllUrlsToQueues(done)
