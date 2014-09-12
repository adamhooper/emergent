fs = require('fs')

JobQueue = require('../job-queue')
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

console.log('Emptying redis...')
jobQueue = new JobQueue(key: 'urls')
jobQueue.clear() # redis commands are queued: this will come before all others

console.log('Initializing work queue...')

buildPopularityHandler = (service) ->
  upf = new UrlPopularityFetcher
    service: service
    fetchLogic: FetchLogic[service]
    log: (args...) -> console.log("[#{service}]: ", args...)
  new UrlTaskQueue
    throttleMs: 613 # be prompt, but don't swamp these services
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

  handleJob = ->
    jobQueue.dequeue (err, url) ->
      throw err if err?
      for __, queue of queues
        queue.queue(url.id, url.url, new Date())
      process.nextTick(handleJob)

  handleJob()

  for __, queue of queues
    queue.startHandling()

  undefined
