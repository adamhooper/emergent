async = require 'async'

Services = [ 'fetch', 'facebook', 'twitter', 'google' ]
DelayInMs = 2 * 3600 * 1000 # 2hrs

populateUrlsFromArticles = (articles, urls, done) ->
  upsertArticleUrl = (article, cb2) ->
    urls.update({ url: article.url }, { $set: { url: article.url } }, { upsert: true }, cb2)

  articles.find({}, { url: 1 }).toArray (err, entries) ->
    return done(err) if err?

    async.each(entries, upsertArticleUrl, done)

scheduleUrls = (urls, queue, done) ->
  t1 = new Date()

  scheduleUrlService = (url, service) ->
    updatedAt = url.shares?[service]?.updatedAt
    if !updatedAt
      queue.queue(service, url._id, url.url, t1)
    else
      t2 = new Date(updatedAt.valueOf() + DelayInMs)
      t2 = t1 if t2 < t1
      queue.queue(service, url._id, url.url, t2)

  urls.find().toArray (err, urls) ->
    return done(err) if err?
    for url in urls
      for service in Services
        scheduleUrlService(url, service)
    done()

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
    @articles = options.articles
    @urls = options.urls
    @queue = options.queue

  run: (done) ->
    @urls.createIndex 'url', { unique: true }, (err) =>
      return done(err) if err?

      populateUrlsFromArticles @articles, @urls, (err) =>
        return done(err) if err?

        scheduleUrls(@urls, @queue, done)
