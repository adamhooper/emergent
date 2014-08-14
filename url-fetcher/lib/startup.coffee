Promise = require('bluebird')

HtmlParser = require('./parser/html_parser')
models = require('../../data-store/lib/models')

Services = [ 'fetch', 'facebook', 'twitter', 'google' ]
FetchThrottling = 619 # ms

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
    dates = {}
    for service in Services
      dates[service] = new Date()

    models.Url.findAllRaw()
      .then (urls) =>
        for url in urls
          for service in Services
            @queues[service].queue(url.id, url.url, dates[service])
            dates[service] = new Date(dates[service].valueOf() + FetchThrottling)
      .nodeify(done)

  runNewParsers: (done) ->
    parseHtml = Promise.promisify(HtmlParser.parse, HtmlParser)

    # FIXME untested! Still prototyping....
    models.Url.findAllUnparsed({ attributes: [ 'id', 'url' ] }, raw: true)
      .then (urls) ->
        # We parse all GETs for one URL in a single transaction. That way, if
        # something fails halfway through, we'll be able to start over. (The
        # only reliable way to tell that parsing failed is if there are exactly
        # zero UrlVersions. 1,000 GETs could translate to one UrlVersion, so
        # if a UrlVersion is present we know nothing.)
        handleOneUrl = (id, url) ->
          console.log("Parsing fetched-but-unparsed URL #{url}...")
          models.sequelize.transaction().then (t) ->
            models.UrlGet.findAll(where: { urlId: id, statusCode: 200 }, order: [[ 'createdAt' ]])
              .then (urlGets) ->
                lastSha1 = null
                next = Promise.resolve(null)
                nParsed = 0
                nInserted = 0
                urlGets.forEach (urlGet) ->
                  # Similar to fetch_handler.coffee
                  next = next
                    .then(-> parseHtml(url, urlGet.body))
                    .then (data) ->
                      nParsed += 1
                      sha1 = models.UrlVersion.calculateSha1Hex(data)
                      if sha1 != lastSha1
                        lastSha1 = sha1
                        nInserted += 1
                        data.urlId = id
                        models.UrlVersion.create(data, null, createdAt: urlGet.createdAt, transaction: t)
                          .then (urlVersion) ->
                            uvid = urlVersion.id
                            Promise.map(
                              models.Article.findAll(where: { urlId: id }),
                              (a) -> models.ArticleVersion.create({ articleId: a.id, urlVersionId: uvid }, null, transaction: t)
                            )
                      else
                        null
                next.then ->
                  console.log("Parsed #{nParsed} and inserted #{nInserted} UrlVersions for URL #{url}.")
                  t.commit()
              .catch (e) ->
                console.log("Failed parsing previously-unparsed URL #{url}: #{e.message}. Skipping....")
                t.rollback()

        next = Promise.resolve(null)
        urls.forEach (url) ->
          next = next.then(-> handleOneUrl(url.id, url.url))
        next
      .nodeify(done)

  run: (done) ->
    @runNewParsers (err) =>
      return done(err) if err
      @addAllUrlsToQueues(done)
