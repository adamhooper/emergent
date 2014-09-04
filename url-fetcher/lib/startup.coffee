Promise = require('bluebird')

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
    @queues = options.queues

  addAllUrlsToQueues: (done) ->
    serviceToNextRunTime = {} # service -> date in ms
    (->
      now = new Date().valueOf()
      for service in Services
        serviceToNextRunTime[service] = now
    )()

    serviceAndIdToLastDate = {} # service -> url id -> date in ms
    # (why are dates in ms? Because we do math on them)

    models.sequelize.query("""
      SELECT 'fetch' AS service, u.id, GREATEST(MAX(uv."createdAt"), MAX(ug."createdAt")) AS "lastDate"
      FROM "Url" u
      LEFT JOIN "UrlVersion" uv ON u.id = uv."urlId"
      LEFT JOIN "UrlGet" ug ON u.id = ug."urlId"
      GROUP BY u.id

      UNION

      SELECT service::varchar AS service, "urlId" AS id, MAX("createdAt") AS "lastDate"
      FROM "UrlPopularityGet"
      GROUP BY "urlId", service
    """)
      .then (rows) ->
        for row in rows
          serviceAndIdToLastDate[row.service] ?= {}
          serviceAndIdToLastDate[row.service][row.id] = row.lastDate.valueOf()
        null
      .then -> models.Url.findAllRaw()
      .then (urls) =>
        for url in urls
          for service in Services
            # Queue it at least FetchDelayInMs after the task was last run (so
            # that restarts have very little impact on scheduling)
            lastDate = serviceAndIdToLastDate[service][url.id]

            nextDate = if lastDate?
              lastDate + FetchDelayInMs
            else
              0

            @queues[service].queue(url.id, url.url, new Date(nextDate))
      .nodeify(done)

  runNewParsers: (done) ->
    finder = new UrlsToReparseFinder(htmlParser: HtmlParser)
    reparser = new UrlReparser(htmlParser: HtmlParser)

    find = Promise.promisify(finder.findUrlsToReparse, finder)
    reparse = Promise.promisify(reparser.reparse, reparser)

    console.log("Looking for URLs that need re-parsing...")
    find()
      .map(((url) ->
        console.log("Reparsing URL #{url.id}: #{url.url}...")
        reparse(url.id, url.url)
          .then(null)
          .catch (e) ->
            console.log("Failed reparse: #{e.message}. Skipping....")
            console.log(e.stack)
      ), concurrency: 1)
      .nodeify(done)

  run: (done) ->
    @runNewParsers (err) =>
      return done(err) if err
      @addAllUrlsToQueues(done)
