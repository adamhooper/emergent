fs = require('fs')
kue = require('kue')

UrlTaskQueue = require('./lib/url_task_queue')
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

# Set up Kue to delete jobs once they're complete
kueQueue.on 'job complete', (id) ->
  kue.Job.get id, (err, job) ->
    throw err if err?
    job.remove() # whenever -- no callback

console.log('Emptying redis...')
kueQueue.client.flushdb()

console.log('Initializing work queue...')

buildPopularityHandler = (service) ->
  upf = new UrlPopularityFetcher
    service: service
    fetchLogic: FetchLogic[service]
    log: (args...) -> console.log("[#{service}]: ", args...)
  new UrlTaskQueue
    task: upf.fetch.bind(upf)
    log: (args...) -> console.log("[#{service} queue]: ", args...)

queues =
  fetch: new UrlTaskQueue
    log: (args...) -> console.log("[fetch queue]: ", args...)
    task: (->
      fh = new FetchHandler
        urlFetcher: new UrlFetcher
        htmlParser: HtmlParser
        log: (args...) -> console.log("[fetch]: ", args...)
      fh.handle.bind(fh)
    )()

for service in Services
  queues[service] = buildPopularityHandler(service)

console.log('Loading URLs...')
startup = new Startup
  queues: queues

startup.run ->
  console.log('Running...')

  kueQueue.process 'url', 20, (job, done) ->
    console.log('Processing', job.data)
    if (url = job.data.incoming)?
      for job in UrlSubJobs
        queues[job].queue(url.id, url.url, new Date())
    else
      throw "Invalid job: " + JSON.stringify(job)

  for __, queue of queues
    queue.startHandling()

  undefined
