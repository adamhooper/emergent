PriorityQueue = require('js-priority-queue')

# A job queue for URLs.
#
# Usage:
#
#   queue = new Queue
#     handlers:
#       facebook: (urlObjectId, url) -> ...
#       twitter: (urlObjectId, url) -> ...
#       ...
#
#   queue.queue('facebook', new ObjectId('123456789012'), 'http://example.org', new Date(new Date().valueOf() + 1000))
#   queue.queue('twitter', ..., ..., ...)
#
#   queue.startHandling()
#   ...
#   queue.stopHandling()
#
# Handlers may push items to the queue; it's entirely okay for a queue to last
# forever.
#
# Notice that the handlers are executed synchronously. They may call background
# tasks (which may even push more stuff onto the queue), but UrlQueue does not
# track which tasks have completed.
module.exports = class UrlQueue
  constructor: (@options) ->
    @handlers = @options.handlers || {}
    @priorityQueue = new PriorityQueue
      comparator: (a, b) -> a.at - b.at # earliest first

  queue: (type, objectId, url, at) ->
    at ?= new Date()
    @priorityQueue.queue(type: type, id: objectId, url: url, at: at)

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
    handler = @handlers[job.type]
    throw "Missing handler for job type #{job.type}" if !handler?
    handler(job.id, job.url)

    setImmediate(=> @_tick())

  startHandling: ->
    @_handling = true
    @_tick()

  stopHandling: ->
    @_scheduleNextHandle(null)
    @_handling = false
