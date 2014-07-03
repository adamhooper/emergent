# Requests a URL and fills in the `url_get` collection.
#
# Usage:
#
#   fetcher.fetch(new ObjectID('53763c763cb763ec6b604920'), 'http://example.org', callback)
#
# This will:
#
# 1. Fetch the URL.
# 2. Insert the `statusCode`, `headers` and `body` into the `url_get`
#    collection, timestamped.
# 3. Call the callback with those three properties.
class UrlFetcher
  constructor: (options) ->
    throw 'Must pass urlGets, a MongoDB Collection' if !options.urlGets

    @urlGets = options.urlGets

    @urlGets.createIndex('urlId', ->) # No hurry. It'll just be nice to have it.

  fetch: (id, url, callback) ->
    UrlFetcher.request.get url, (err, response) =>
      return callback(err) if err?

      data =
        urlId: id
        createdAt: new Date()
        statusCode: response.statusCode
        headers: response.headers
        body: response.body

      @urlGets.insert(data, callback)

UrlFetcher.request = require('request') # so we can stub it out during tests

module.exports = UrlFetcher
