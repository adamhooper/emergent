Promise = require('bluebird')
models = require('../../data-store').models

UrlPopularityGet = models.UrlPopularityGet

DelayInMs = 2 * 3600 * 1000 # 2hrs

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

    @service = options.service
    @fetchLogic = options.fetchLogic
    @fetchLogicPromise = Promise.promisify(@fetchLogic)

  fetch: (queue, urlId, url, done) ->
    @fetchLogicPromise(url)
      .then (data) =>
        UrlPopularityGet.create
          urlId: urlId
          service: @service
          shares: data.n
          rawData: data.rawData
      .finally(=> queue.queue(urlId, url, new Date(new Date().valueOf() + DelayInMs)))
      .nodeify(done)
