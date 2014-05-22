async = require('async')
kue = require('kue')
mongodb = require('mongodb')

Queue = require('./lib/queue')
Startup = require('./lib/startup')
UrlPopularityFetcher = require('./lib/url_popularity_fetcher')

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
    mongodb.MongoClient.connect 'mongodb://localhost/truthmaker', (err, result) ->
      db = result
      cb(err, result)

  (cb) -> # Start with a clear slate
    # Empty Redis first
    kueQueue.client.flushdb()
    startup = new Startup
      articles: db.collection('article')
      urls: db.collection('url')
      queue: queue
    startup.run(cb)

  (cb) -> # Process the queue
    fetcher = new UrlPopularityFetcher
      urls: db.collection('url')
      urlFetches: db.collection('url_fetch')
      fetchLogic:
        facebook: require('./lib/fetch-logic/facebook')
        twitter: require('./lib/fetch-logic/twitter')
        google: require('./lib/fetch-logic/google')
      queue: queue

    kueQueue.process 'url', 20, (job, done) ->
      fetcher.fetch(job.data.service, job.data.urlId, done)
    # This never ends
], (err) ->
  throw err if err?
