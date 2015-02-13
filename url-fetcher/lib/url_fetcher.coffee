models = require('../../data-store').models

UrlGet = models.UrlGet

MaxUrlGetAgeInMs = 86400 * 1000 * 31 # DELETE all UrlGets older than this

# Requests a URL and fills in the `url_get` collection.
#
# Usage:
#
#   fetcher.fetch('393dc48b-6c2b-4fdb-b1cd-9882e5f94616', 'http://example.org', callback)
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

    options =
      url: url
      headers:
        'User-Agent': 'EmergentBot (+http://www.emergent.info)'

    UrlFetcher.request.get options, (err, response) =>
      return done(err) if err?

      data =
        urlId: id
        statusCode: response.statusCode
        responseHeaders: JSON.stringify(response.headers)
        body: response.body

      UrlGet.create(data)
        .catch (err) =>
          # TODO: get rid of Sequelize here. It doesn't escape strings properly.
          console.warn(err)
          console.warn(err.stack)
          throw err
        .nodeify(done)

UrlFetcher.request = require('request') # so we can stub it out during tests

module.exports = UrlFetcher
