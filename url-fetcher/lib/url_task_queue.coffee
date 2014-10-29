PriorityQueue = require('js-priority-queue')
ms = require('ms')

strcmp = (a, b) ->
  if a < b
    -1
  else if a > b
    1
  else 0

# Does something to a URL at a scheduled time.
# A job queue for URLs.
#
# Usage:
#
#   queue = new UrlTaskQueue
#       task: (queue, urlId, url) -> ...
#       throttleMs: 123 # Minimum delay between starting two tasks
#       log: console.log
#
#   queue.queue('e91beed9-bfb7-44af-9609-ab10736347c1', 'http://example.org', new Date(new Date().valueOf() + 1000))
#
#   queue.startHandling()
#   ...
#   queue.stopHandling()
#
# The task may push new items to the queue for itself; it's entirely okay for
# a queue to never empty.
#
# Notice that the task needn't call a callback. Its return value would be
# ignored. That's so that many tasks can run at once.
module.exports = class UrlTaskQueue
  constructor: (options) ->
    throw 'Must pass options.task, a Function that takes (urlId, url)' if !options?.task

    @task = options.task
    @throttleMs = options.throttleMs ? 0
    @log = options.log ? require('debug')('UrlTaskQueue')
    @_lastTick = null

    @priorityQueue = new PriorityQueue
      comparator: (a, b) ->
        (a.at - b.at) || strcmp(a.id, b.id) # earliest first, then tie-break

  queue: (job) ->
    throw 'Must pass job.urlId' if !job.urlId?
    throw 'Must pass job url' if !job.url?
    throw 'Must pass job.at' if !job.at?
    throw 'Must pass job.nPreviousFetches' if !job.nPreviousFetches?

    @log("queueing #{job.urlId} #{job.url} in #{ms(job.at - new Date())}")

    @priorityQueue.queue(job)

    if @_handling
      @_tick()

  _scheduleNextHandle: (ms) ->
    if @_timeout?
      clearTimeout(@_timeout)

    @_timeout = if ms?
      setTimeout((=> @_handleOne()), ms)
    else
      null

  _tick: ->
    if @priorityQueue.length
      now = new Date().valueOf()
      next = @priorityQueue.peek().at

      distanceToHandle = next - now
      if @_lastHandle?
        distanceToHandle = Math.max(distanceToHandle, @_lastHandle - now + @throttleMs)

      if distanceToHandle <= 0
        @_handleOne()
      else
        @_scheduleNextHandle(distanceToHandle)

  _handleOne: ->
    @_lastHandle = new Date().valueOf()
    @_scheduleNextHandle(null)
    @_timeout = setTimeout((=> @_tick()), @throttleMs)

    job = @priorityQueue.dequeue()
    @log("handling #{job.urlId} #{job.url}")
    @task(@, job)

  startHandling: ->
    @_handling = true
    @_tick()

  stopHandling: ->
    @_scheduleNextHandle(null)
    @_handling = false
