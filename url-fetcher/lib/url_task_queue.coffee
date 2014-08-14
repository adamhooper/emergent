PriorityQueue = require('js-priority-queue')

# Does something to a URL at a scheduled time.
# A job queue for URLs.
#
# Usage:
#
#   queue = new UrlTaskQueue
#       task: (queue, urlId, url) -> ...
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
    @log = options.log ? console.log
    @priorityQueue = new PriorityQueue
      comparator: (a, b) -> a.at - b.at # earliest first

  queue: (urlId, url, at) ->
    throw 'Must pass urlId, url and at' if !at?
    @priorityQueue.queue(id: urlId, url: url, at: at)

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
      now = new Date()
      next = @priorityQueue.peek().at
      if now >= next
        @_handleOne()
      else
        @_scheduleNextHandle(next - now)

  _handleOne: ->
    @_timeout = null

    job = @priorityQueue.dequeue()
    @log("handling (#{job.id} #{job.url})")
    @task(@, job.id, job.url)

    setImmediate(=> @_tick())

  startHandling: ->
    @_handling = true
    @_tick()

  stopHandling: ->
    @_scheduleNextHandle(null)
    @_handling = false
