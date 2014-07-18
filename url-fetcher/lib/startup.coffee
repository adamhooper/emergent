Promise = require('bluebird')
models = require('../../data-store/lib/models')

Services = [ 'fetch', 'facebook', 'twitter', 'google' ]
FetchThrottling = 619 # ms

# Pushes all URLs to the queue.
#
# Be sure to empty out the queue beforehand!
module.exports = class Startup
  # Arguments:
  #
  # * `articles` a Mongo `Collection`
  # * `urls` a Mongo `Collection`
  # * `queue` a `Queue`
  constructor: (options) ->
    @queue = options.queue

  run: (done) ->
    date = new Date()

    models.Url.findAllRaw()
      .then (urls) =>
        for url in urls
          for service in Services
            @queue.queue(service, url.id, url.url, date)
          date = new Date(date.valueOf() + FetchThrottling)
      .nodeify(done)
