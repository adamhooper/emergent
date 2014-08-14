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
# 3. Queue another update in the future
module.exports = class UrlPopularityFetcher
  constructor: (options) ->
    throw 'Must pass queues, an Object mapping service name to UrlTaskQueue' if !options.queues
    @queues = options.queues

    @fetchLogic = {}
    for k, v of options.fetchLogic
      @fetchLogic[k] = Promise.promisify(v)
    undefined

  fetch: (service, urlId, url, done) ->
    @fetchLogic[service](url)
      .then (data) ->
        UrlPopularityGet.create
          urlId: urlId
          service: service
          shares: data.n
          rawData: data.rawData
      .finally(=> @queues[service].queue(urlId, url, new Date(new Date().valueOf() + DelayInMs)))
      .nodeify(done)
