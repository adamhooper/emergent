async = require('async')
fs = require('fs')
kue = require('kue')
mongodb = require('mongodb')

Queue = require('./lib/queue')
Startup = require('./lib/startup')
UrlCreator = require('./lib/url_creator')
UrlFetcher = require('./lib/url_fetcher')
UrlPopularityFetcher = require('./lib/url_popularity_fetcher')
Services = [ 'facebook', 'twitter', 'google' ]
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

    buildHandler = (service) -> ((id, url) -> popularityFetcher.fetch(service, id, url))
    (handlers[service] = buildHandler(service)) for service in Services
    handlers.fetch = (id, url) -> urlFetcher.fetch(id, url)

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
      services: Services

    kueQueue.process 'url', 20, (job, done) ->
      console.log('Processing', job.data)
      if (url = job.data.incoming)?
        creator.create(url, done)
      else
        throw "Invalid job: " + JSON.stringify(job)

    queue.startHandling()
], (err) ->
  throw err if err?
