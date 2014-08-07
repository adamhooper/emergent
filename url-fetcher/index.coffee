async = require('async')
fs = require('fs')
kue = require('kue')

Queue = require('./lib/queue')
Startup = require('./lib/startup')
HtmlParser = require('./lib/parser/html_parser')
UrlFetcher = require('./lib/url_fetcher')
FetchHandler = require('./lib/fetch_handler')
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

    fetchHandler = new FetchHandler
      queue: queue
      urlFetcher: urlFetcher
      htmlParser: HtmlParser

    handlers.fetch = fetchHandler.handle.bind(fetchHandler)

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
