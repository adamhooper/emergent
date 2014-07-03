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
# 3. Update the `url` to have `urlGet.id` and `urlGet.updatedAt`.
# 4. Call the callback with the `url_get` record.
class UrlFetcher
  constructor: (options) ->
    throw 'Must pass urlGets, a MongoDB Collection' if !options.urlGets
    throw 'Must pass urls, a MongoDB Collection' if !options.urls

    @urls = options.urls
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

      @urlGets.insert data, (err, urlGetResponse) =>
        return callback(err) if err?

        $set =
          'urlGet.id': urlGetResponse._id
          'urlGet.updatedAt': data.createdAt

        @urls.update { _id: data.urlId }, { $set: $set }, (err) ->
          return callback(err) if err?
          callback(null, urlGetResponse)

UrlFetcher.request = require('request') # so we can stub it out during tests

module.exports = UrlFetcher
