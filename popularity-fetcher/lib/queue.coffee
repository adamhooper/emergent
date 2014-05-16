# A job queue, backed by [kue](https://github.com/learnboost/kue)
#
# Usage:
#
#   kueQueue = require('kue').createQueue()
#   queue = new Queue(kueQueue)
#
#   # fetch URL ASAP
#   queue.push('facebook', urlObjectId, callback)
#   # fetch 1 second from now
#   queue.pushWithDelay('facebook', urlObjectId, 1000, callback)
#
#   # (You don't pop from this queue. Use kueQueue's methods to handle jobs.)
#
# We use Kue because we expect to scale to lots and lots of URLs, all with
# different timings. setTimeout() would cost too much memory for all the
# closures; a more clever implementation of a priority queue is doable, but
# we'd be reinventing the wheel.
module.exports = class UrlFetcherQueue
  constructor: (@kueQueue) ->

  _createJob: (service, objectId) ->
    objectId = objectId.str if objectId.str?
    data =
      service: service
      urlId: objectId

    @kueQueue.createJob('url', data)

  push: (service, objectId, done) ->
    @_createJob(service, objectId).save(done)

  pushWithDelay: (service, objectId, delayMs, done) ->
    @_createJob(service, objectId).delay(delayMs).save(done)
