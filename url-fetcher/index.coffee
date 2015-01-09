process.env.DEBUG='*' if !process.env.DEBUG

fs = require('fs')
debug = require('debug')('index')

FetchHandler = require('./lib/fetch_handler')
HtmlParser = require('./lib/parser/html_parser')
JobQueue = require('../job-queue')
Startup = require('./lib/startup')
TaskTimeChooser = require('./lib/task_time_chooser')
UrlFetcher = require('./lib/url_fetcher')
UrlPopularityFetcher = require('./lib/url_popularity_fetcher')
UrlTaskQueue = require('./lib/url_task_queue')
UserSubmittedClaimTracker = require('./lib/user_submitted_claim_tracker')

Services = [ 'facebook', 'twitter', 'google' ]
UrlSubJobs = [ 'fetch', 'facebook', 'twitter', 'google' ]
FetchLogic = {}
(->
  for service in Services
    FetchLogic[service] = require("./lib/fetch-logic/#{service}")
  FetchLogic.facebook.access_token = fs.readFileSync(__dirname + '/../../facebook-app-token', 'ascii').trim()
)()

debug('Emptying redis...')
jobQueue = new JobQueue(key: 'urls')
jobQueue.clear() # redis commands are queued: this will come before all others

userSubmittedClaimTracker = new UserSubmittedClaimTracker(jobQueue: jobQueue)

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

debug('Initializing work queue...')

buildPopularityHandler = (service) ->
  upf = new UrlPopularityFetcher
    service: service
    fetchLogic: FetchLogic[service]
    taskTimeChooser: taskTimeChooser
    log: require('debug')("fetch:#{service}")
  new UrlTaskQueue
    throttleMs: 613 # be prompt, but don't swamp these services
    task: upf.fetch.bind(upf)
    log: require('debug')("queue:#{service}")

queues =
  fetch: new UrlTaskQueue
    log: require('debug')("queue:url")
    task: (->
      fh = new FetchHandler
        urlFetcher: new UrlFetcher
        htmlParser: HtmlParser
        taskTimeChooser: taskTimeChooser
        log: require('debug')("fetch:url")
      fh.handle.bind(fh)
    )()

for service in Services
  queues[service] = buildPopularityHandler(service)

debug('Loading URLs...')
startup = new Startup
  taskTimeChooser: taskTimeChooser
  queues: queues

startup.run (err) ->
  throw err if err?
  debug('Running...')

  handleJob = ->
    jobQueue.dequeue (err, url) ->
      throw err if err?
      for __, queue of queues
        queue.queue
          urlId: url.id
          url: url.url
          at: new Date()
          nPreviousFetches: 0
      process.nextTick(handleJob)

  handleJob()

  for __, queue of queues
    queue.startHandling()

  userSubmittedClaimTracker.trackRandomUntrackedUrl()
  setTimeout((-> userSubmittedClaimTracker.trackRandomUntrackedUrl()), 10*60*1000) # one every 10min

  undefined
