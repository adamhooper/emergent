async = require('async')
kue = require('kue')
mongodb = require('mongodb')

Queue = require('./lib/queue')
Startup = require('./lib/startup')
UrlPopularityFetcher = require('./lib/url_popularity_fetcher')

require('./lib/fetch-logic/facebook').access_token = require('fs').readFileSync('../../facebook-app-token', 'ascii').trim()

kueQueue = kue.createQueue()
db = undefined

queue = new Queue(kueQueue)

# Set up Kue to delete jobs once they're complete
kueQueue.on 'job complete', (id) ->
  console.log("Job #{id} complete. Deleting...")
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
    fetcher = new UrlPopularityFetcher
      urls: db.collection('url')
      urlFetches: db.collection('url_fetch')
      fetchLogic:
        facebook: require('./lib/fetch-logic/facebook')
        twitter: require('./lib/fetch-logic/twitter')
        google: require('./lib/fetch-logic/google')
      queue: queue

    kueQueue.process 'url', 20, (job, done) ->
      console.log('Processing', job.data)
      fetcher.fetch(job.data.service, job.data.urlId, done)
    # This never ends
], (err) ->
  throw err if err?
