Promise = require('bluebird')
models = require('../../data-store').models

UrlPopularityGet = models.UrlPopularityGet

DelayInMs = 1 * 3600 * 1000 # 1hr

# Finds URL popularity and updates the `url` and `url_fetch` collections.
#
# Usage:
#
#   fetcher.fetch('facebook', new ObjectID('53763c763cb763ec6b604920'), 'http://example.org', callback)
#
# This will:
#
# 1. Query facebook for the URL's popularity (returning a number)
# 2. Update the `url` and `url_fetch` collections with the new popularity
module.exports = class UrlPopularityFetcher
  constructor: (options) ->
    throw 'Must pass service, a String' if !options.service
    throw 'Must pass fetchLogic, a Function' if !options.fetchLogic
    throw 'Must pass taskTimeChooser, a TaskTimeChooser' if !options.taskTimeChooser

    @service = options.service
    @fetchLogic = options.fetchLogic
    @fetchLogicPromise = Promise.promisify(@fetchLogic)
    @taskTimeChooser = options.taskTimeChooser

  fetch: (queue, job, done) ->
    urlId = job.urlId
    url = job.url
    nPreviousFetches = job.nPreviousFetches
    @fetchLogicPromise(url)
      .then (data) =>
        UrlPopularityGet.create
          urlId: urlId
          service: @service
          shares: data.n
          rawData: data.rawData
      .finally =>
        nFetches = nPreviousFetches + 1
        nextDate = @taskTimeChooser.chooseTime(nFetches, new Date())
        if nextDate?
          queue.queue
            urlId: urlId
            url: url
            nPreviousFetches: nFetches
            at: nextDate
      .nodeify(done)
