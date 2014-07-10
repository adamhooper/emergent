async = require('async')

module.exports = class UrlCreator
  constructor: (options) ->
    @urls = options.urls
    @queue = options.queue
    @services = options.services

  create: (url, done) ->
    @urls.update { url: url }, { $set: { url: url } }, { w: 1, upsert: true }, (err, result, extra) =>
      return done(err) if err?

      if extra.updatedExisting
        # The URL was already in the database, so we have already scheduled a
        # refresh of its popularity.
        done()
      else
        id = extra.upserted
        for service in @services
          @queue.queue(service, id, url)
        done()
