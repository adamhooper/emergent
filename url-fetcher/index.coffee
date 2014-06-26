async = require('async')
fs = require('fs')
kue = require('kue')
mongodb = require('mongodb')

Queue = require('./lib/queue')
Startup = require('./lib/startup')
UrlCreator = require('./lib/url_creator')
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

queue = new Queue(kueQueue)

# Set up Kue to delete jobs once they're complete
kueQueue.on 'job complete', (id) ->
  kue.Job.get id, (err, job) ->
    throw err if err?
    job.remove() # whenever -- no callback

async.series [
  (cb) -> # Connect to MongoDB
    console.log('Connecting to mongodb://localhost/truthmaker')
    mongodb.MongoClient.connect 'mongodb://localhost/truthmaker', (err, result) ->
      db = result
      cb(err, result)

  (cb) -> # Start with a clear slate
    # Empty Redis first
    console.log('Emptying redis')
    kueQueue.client.flushdb()
    startup = new Startup
      articles: db.collection('article')
      urls: db.collection('url')
      queue: queue
    startup.run(cb)

  (cb) -> # Process the queue
    console.log('Initializing fetchers')

    creator = new UrlCreator
      urls: db.collection('url')
      queue: queue
      services: Services

    fetcher = new UrlPopularityFetcher
      urls: db.collection('url')
      urlFetches: db.collection('url_fetch')
      fetchLogic: FetchLogic
      queue: queue

    kueQueue.process 'url', 20, (job, done) ->
      console.log('Processing', job.data)
      if (url = job.data.incoming)?
        creator.create(url, done)
      else
        fetcher.fetch(job.data.service, job.data.urlId, done)
    # This never ends
], (err) ->
  throw err if err?
