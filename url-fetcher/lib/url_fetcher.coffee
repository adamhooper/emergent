models = require('../../data-store').models

UrlGet = models.UrlGet

MaxUrlGetAgeInMs = 86400 * 1000 * 21 # DELETE  all UrlGets older than this

# Requests a URL and fills in the `url_get` collection.
#
# Usage:
#
#   fetcher.fetch(new ObjectID('53763c763cb763ec6b604920'), 'http://example.org', callback)
#
# This will:
#
# 1. Fetch the URL.
# 2. Insert the `statusCode`, `headers` and `body` into the UrlGet table.
# 3. DELETE ancient UrlGets (to save space).
# 3. Call the callback with the `url_get` record.
class UrlFetcher
  fetch: (id, url, done) ->
    done ?= (->)

    UrlFetcher.request.get url, (err, response) =>
      return done(err) if err?

      data =
        urlId: id
        statusCode: response.statusCode
        responseHeaders: JSON.stringify(response.headers)
        body: response.body

      UrlGet.create(data)
        .tap ->
          UrlGet.destroy(urlId: id, createdAt: { lt: new Date(new Date().valueOf() - MaxUrlGetAgeInMs) })
          null # ignore return value
        .nodeify(done)

UrlFetcher.request = require('request') # so we can stub it out during tests

module.exports = UrlFetcher
