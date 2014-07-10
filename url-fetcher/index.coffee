async = require('async')
fs = require('fs')
kue = require('kue')
mongodb = require('mongodb')

FetchDelay = 2 * 3600 * 1000 # 2h, in ms. Time after a fetch before the next fetch of the same URL.

Queue = require('./lib/queue')
Startup = require('./lib/startup')
HtmlParser = require('./lib/parser/html_parser')
UrlCreator = require('./lib/url_creator')
UrlFetcher = require('./lib/url_fetcher')
UrlPopularityFetcher = require('./lib/url_popularity_fetcher')
UrlVersionStore = require('./lib/url_version_store')
Services = [ 'facebook', 'twitter', 'google' ]
UrlSubJobs = [ 'fetch', 'facebook', 'twitter', 'google' ]
FetchLogic = {}
(->
  for service in Services
    FetchLogic[service] = require("./lib/fetch-logic/#{service}")
  FetchLogic.facebook.access_token = fs.readFileSync(__dirname + '/../../facebook-app-token', 'ascii').trim()
)()

kueQueue = kue.createQueue()
db = undefined
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
    console.log('Connecting to mongodb://localhost/truthmaker...')
    mongodb.MongoClient.connect 'mongodb://localhost/truthmaker', (err, result) ->
      db = result
      cb(err, result)

  (cb) ->
    console.log('Initializing work queue...')

    handlers = {}
    queue = new Queue
      handlers: handlers

    urlFetcher = new UrlFetcher
      urls: db.collection('url')
      urlGets: db.collection('url_get')

    popularityFetcher = new UrlPopularityFetcher
      urls: db.collection('url')
      urlFetches: db.collection('url_fetch')
      fetchLogic: FetchLogic
      queue: queue

    urlVersionStore = new UrlVersionStore
      urlVersions: db.collection('url_version')

    buildHandler = (service) -> ((id, url) -> popularityFetcher.fetch(service, id, url))
    (handlers[service] = buildHandler(service)) for service in Services

    handlers.fetch = (id, url) ->
      # Fetch the request and store it
      urlFetcher.fetch id, url, (err, urlGetRecord) ->
        # Do it again in the future
        queue.queue('fetch', id, url, new Date(new Date().valueOf() + FetchDelay))

        return console.log("urlFetcher error for #{url}:", err) if err?
        return console.log("bad response for #{url}: #{urlGetRecord.statusCode}") if urlGetRecord.statusCode != 200

        # Parse the HTML
        HtmlParser.parse url, urlGetRecord.body, (err, data) ->
          return console.log("parse error for #{url}:", err) if err?

          # Store the parsed HTML
          data.urlId = id
          urlVersionStore.insert data, (err) ->
            return console.log("error inserting parsed #{url}", err) if err?

    cb()

  (cb) ->
    console.log('Loading URLs...')
    startup = new Startup
      articles: db.collection('article')
      urls: db.collection('url')
      queue: queue
    startup.run(cb)

  (cb) -> # Process the queue
    console.log('Running...')

    creator = new UrlCreator
      urls: db.collection('url')
      queue: queue
      services: UrlSubJobs

    kueQueue.process 'url', 20, (job, done) ->
      console.log('Processing', job.data)
      if (url = job.data.incoming)?
        creator.create(url, done)
      else
        throw "Invalid job: " + JSON.stringify(job)

    queue.startHandling()
], (err) ->
  throw err if err?
