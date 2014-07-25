async = require('async')
fs = require('fs')
kue = require('kue')
models = require('../data-store').models

FetchDelay = 2 * 3600 * 1000 # 2h, in ms. Time after a fetch before the next fetch of the same URL.

_ = require('lodash')
Promise = require('bluebird')
Queue = require('./lib/queue')
Startup = require('./lib/startup')
HtmlParser = require('./lib/parser/html_parser')
UrlFetcher = require('./lib/url_fetcher')
UrlPopularityFetcher = require('./lib/url_popularity_fetcher')
Services = [ 'facebook', 'twitter', 'google' ]
UrlSubJobs = [ 'fetch', 'facebook', 'twitter', 'google' ]
FetchLogic = {}
(->
  for service in Services
    FetchLogic[service] = require("./lib/fetch-logic/#{service}")
  FetchLogic.facebook.access_token = fs.readFileSync(__dirname + '/../../facebook-app-token', 'ascii').trim()
)()

kueQueue = kue.createQueue()
queue = undefined

# Set up Kue to delete jobs once they're complete
kueQueue.on 'job complete', (id) ->
  kue.Job.get id, (err, job) ->
    throw err if err?
    job.remove() # whenever -- no callback

console.log('Emptying redis...')
kueQueue.client.flushdb()

async.series [
  (cb) ->
    console.log('Initializing work queue...')

    handlers = {}
    queue = new Queue
      handlers: handlers

    urlFetcher = new UrlFetcher()

    popularityFetcher = new UrlPopularityFetcher
      fetchLogic: FetchLogic
      queue: queue

    buildHandler = (service) -> ((id, url) -> popularityFetcher.fetch(service, id, url))
    (handlers[service] = buildHandler(service)) for service in Services

    urlFetchAsync = Promise.promisify(urlFetcher.fetch)
    parseHtmlAsync = Promise.promisify(HtmlParser.parse)

    handlers.fetch = (id, url) ->
      urlFetchAsync(id, url)
        .then((urlGet) -> throw new Error("bad response for #{url}: #{urlGet.statusCode}") if urlGet.statusCode != 200; urlGet)
        .then (urlGet) ->
          parseHtmlAsync(url, urlGet.body)
            .then((data) -> models.UrlVersion.create(_.extend({ urlId: id, urlGetId: urlGet.id }, data)))
            .then (urlVersion) ->
              articles = models.Article.findAllRaw({ where: { urlId: id } })
              createVersion = (article) -> models.ArticleVersion.create(articleId: article.id, urlVersionId: urlVersion.id)
              Promise.map(articles, createVersion)
        .catch((err) -> console.warn("non-fatal error fetching #{url}", err))
        .finally(-> queue.queue('fetch', id, url, new Date(new Date().valueOf() + FetchDelay)))

    cb()

  (cb) ->
    console.log('Loading URLs...')
    startup = new Startup
      queue: queue
    startup.run(cb)

  (cb) -> # Process the queue
    console.log('Running...')

    kueQueue.process 'url', 20, (job, done) ->
      console.log('Processing', job.data)
      if (url = job.data.incoming)?
        for job in UrlSubJobs
          queue.queue(job, url.id, url.url, new Date())
      else
        throw "Invalid job: " + JSON.stringify(job)

    queue.startHandling()
], (err) ->
  throw err if err?
