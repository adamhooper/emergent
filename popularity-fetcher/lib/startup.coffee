async = require 'async'

Services = [ 'facebook', 'twitter', 'google' ]
DelayInMs = 2 * 3600 * 1000 # 2hrs

populateUrlsFromArticles = (articles, urls, done) ->
  upsertArticleUrl = (article, cb2) ->
    urls.update({ url: article.url }, { url: article.url }, { upsert: true }, cb2)

  articles.find {}, { url: 1 }, (err, entries) ->
    return done(err) if err?

    async.each(entries, upsertArticleUrl, done)

scheduleUrls = (urls, queue, done) ->
  t1 = new Date()

  scheduleUrlService = (url, service, callback) ->
    updatedAt = url.shares?[service]?.updatedAt
    delay = updatedAt - t1 + DelayInMs # if !updatedAt?, this is NaN
    if delay > -1 # if NaN, this is false
      queue.pushWithDelay(service, url._id, delay, callback)
    else
      queue.push(service, url._id, callback)

  scheduleUrl = (url, callback) ->
    async.map(Services, ((service, cb) -> scheduleUrlService(url, service, cb)), callback)

  urls.find (err, urls) ->
    return done(err) if err?
    async.each(urls, scheduleUrl, done)

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
    populateUrlsFromArticles @articles, @urls, (err) =>
      return done(err) if err?

      scheduleUrls(@urls, @queue, done)
