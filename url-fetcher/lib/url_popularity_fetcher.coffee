async = require('async')
ObjectID = require('mongodb').ObjectID

DelayInMs = 2 * 3600 * 1000 # 2hrs

insertData = (urlFetches, urls, service, urlId, data, done) ->
  now = new Date()

  data.service = service
  data.urlId = urlId
  data.createdAt = now

  $set = {}
  $set["shares.#{service}.n"] = data.n
  $set["shares.#{service}.updatedAt"] = now

  async.parallel([
    (done) -> urlFetches.insert(data, done)
    (done) -> urls.update({ _id: urlId }, { '$set', $set }, done)
  ], done)

# Finds URL popularity and updates the `url` and `url_fetch` collections.
#
# Usage:
#
#   fetcher.fetch('facebook', '53763c763cb763ec6b604920', callback)
#
# This will:
#
# 1. Fetch the URL with ID '53763c763cb763ec6b604920'
# 2. Query facebook for that URL's popularity (returning a number)
# 3. Update the `url` and `url_fetch` collections with the new popularity
# 4. Queue another update in the future
module.exports = class UrlPopularityFetcher
  constructor: (options) ->
    @urls = options.urls
    @urlFetches = options.urlFetches
    @queue = options.queue
    @fetchLogic = options.fetchLogic

    @urlFetches.createIndex('urlId', ->) # No hurry. It'll just be nice to have it.

  fetch: (service, urlId, url, done) ->
    @fetchLogic[service] url, (err, data) =>
      return done(err) if err?

      insertData @urlFetches, @urls, service, urlId, data, (err) =>
        return done(err) if err?

        @queue.queue(service, urlId, url, new Date(new Date().valueOf() + DelayInMs))
        done?()
