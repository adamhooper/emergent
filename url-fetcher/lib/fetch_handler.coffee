_ = require('lodash')
Promise = require('bluebird')

models = require('../../data-store').models

FetchDelayInMs = 1 * 3600 * 1000 # 1hr

module.exports = class FetchHandler
  constructor: (options) ->
    throw 'Must pass options.htmlParser, an HtmlParser' if !options.htmlParser
    throw 'Must pass options.urlFetcher, a UrlFetcher' if !options.urlFetcher

    @log = options.log || console.log
    @htmlParser = options.htmlParser
    urlFetcher = options.urlFetcher

    @_fetch = Promise.promisify(urlFetcher.fetch, urlFetcher)

  handle: (queue, id, url, done) ->
    @_fetch(id, url)
      .then (urlGet) =>
        if urlGet.statusCode != 200
          throw new Error("#{url} gave HTTP status #{urlGet.statusCode}")
        [ urlGet, @htmlParser.parse(url, urlGet.body) ]
      .spread (urlGet, parsed) ->
        sha1 = models.UrlVersion.calculateSha1Hex(parsed)
        # Check the last-stored UrlVersion. Create a new one if it's different.
        models.UrlVersion.find(where: { urlId: id }, order: [[ 'createdAt', 'DESC' ]])
          .then (prev) ->
            if prev?.sha1 == sha1
              null
            else
              models.UrlGet.max('createdAt', where: {
                urlId: id
                createdAt: { lt: urlGet.createdAt }
              })
                .then (previousUrlGetCreatedAt) ->
                  ms = if previousUrlGetCreatedAt
                    urlGet.createdAt - previousUrlGetCreatedAt
                  else
                    null
                  data = _.extend({
                    urlId: id
                    millisecondsSincePreviousUrlGet: ms
                  }, parsed)
                  models.UrlVersion.create(data, null)
      .then (newUvOrNull) =>
        if (uvid = newUvOrNull?.id)?
          @log("FetchHandler.handle created new UrlVersion for #{url}")
          Promise.map(
            models.Article.findAll(where: { urlId: id }),
            (a) -> models.ArticleVersion.create(articleId: a.id, urlVersionId: uvid)
          )
        else
          @log("FetchHandler.handle determined #{url} did not change")
          null
      .catch((e) => @log("FetchHandler.handle error: #{e.message}"))
      .finally(=> queue.queue(id, url, new Date(new Date().valueOf() + FetchDelayInMs)))
      .nodeify(done)
