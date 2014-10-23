fs = require('fs')

FetchHandler = require('./lib/fetch_handler')
HtmlParser = require('./lib/parser/html_parser')
JobQueue = require('../job-queue')
Startup = require('./lib/startup')
TaskTimeChooser = require('./lib/task_time_chooser')
UrlFetcher = require('./lib/url_fetcher')
UrlPopularityFetcher = require('./lib/url_popularity_fetcher')
UrlTaskQueue = require('./lib/url_task_queue')

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

taskTimeChooser = (->
  # Build up "delays", a set of timeouts: 4x15min, 4x30min, 4x1h, ..., 4x256h
  delays = [ 0 ]
  delay = 15 * 60 * 1000 # 15min
  while delay <= 256 * 3600 * 1000 # 256h
    for i in [ 0 .. 3 ]
      delays.push(delay)
    delay *= 2

  new TaskTimeChooser(delays: delays)
)()

console.log('Initializing work queue...')

buildPopularityHandler = (service) ->
  upf = new UrlPopularityFetcher
    service: service
    fetchLogic: FetchLogic[service]
    taskTimeChooser: taskTimeChooser
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
        taskTimeChooser: taskTimeChooser
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
