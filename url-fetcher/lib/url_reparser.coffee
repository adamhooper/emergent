Promise = require('bluebird')
_ = require('lodash')

models = require('../../data-store').models

module.exports = class UrlReparser
  constructor: (options) ->
    throw 'Must pass options.htmlParser, an HtmlParser' if 'htmlParser' not of options

    @_parse = options.htmlParser.parse.bind(options.htmlParser)
    @_log = options?.log ? require('debug')('UrlReparser')

  # A reparse is like a merge.
  #
  # We fetch all UrlGets, and all UrlVersions that were automatically
  # generated. (We ignore manually-edited or manually-created UrlGets.) Both
  # are sorted chronologically. We can _derive_, from a UrlGet, a "best"
  # UrlVersion -- that is, a UrlVersion that we _would_ have gotten had we
  # been using the most recent parser version.
  #
  # So we iterate over all UrlGets, building "best" UrlVersions. We keep an
  # eye on the _actual_ UrlVersions in the database. (Remember, duplicate
  # UrlVersions don't appear in the database; we infer them.)
  #
  # For any "best" UrlVersion, keeping in mind our spot along the timeline,
  # we check:
  #
  # * Is it missing from the database? If so, add it (and ArticleVersions).
  # * Is it identical to an existing UrlVersion in the database? If so,
  #   ensure it has the latest parserVersion and move on.
  # * Is it different from the latest UrlVersion in the database? If so,
  #   overwrite the UrlVersion and clear its ArticleVersions.
  reparse: (urlId, url, done) ->
    Promise.all([
      models.UrlGet.findAll(where: { urlId: urlId, statusCode: 200 }, order: [ [ 'createdAt' ] ])
      models.UrlVersion.findAll(where: { urlId: urlId, urlGetId: { ne: null }, createdBy: null }, order: [ [ 'createdAt' ] ])
    ])
      .spread(@_merge.bind(@, urlId, url))
      .then(null)
      .nodeify(done)

  _urlGetToUrlVersion: (urlGet, url) ->
    data = @_parse(url, urlGet.body)
    _.extend(data, {
      urlGetId: urlGet.id
      urlId: urlGet.urlId
      sha1: models.UrlVersion.calculateSha1Hex(data)
    })

  _createUrlVersion: (urlVersion, createdAt, transaction) ->
    @_log("UrlVersion.create urlId #{urlVersion.urlId}, urlGetId #{urlVersion.urlGetId}, sha1 #{urlVersion.sha1}, date #{createdAt.toISOString()}")
    models.UrlVersion.create(urlVersion, null, createdAt: createdAt, transaction: transaction)
      .then((x) -> x.id)
      .then (urlVersionId) ->
        models.Article.findAll({ where: { urlId: urlVersion.urlId } }, transaction: transaction)
          .map((article) -> models.ArticleVersion.create({ urlVersionId: urlVersionId, articleId: article.id }, null, transaction: transaction))

  _updateUrlVersionParserVersion: (urlVersion, parserVersion, transaction) ->
    @_log("UrlVersion.update (urlId #{urlVersion.urlId}, urlGetId #{urlVersion.urlGetId}, sha1 #{urlVersion.sha1}, just setting parserVersion #{parserVersion}")
    models.UrlVersion.update(urlVersion, { parserVersion: parserVersion }, null, transaction: transaction)

  _updateUrlVersion: (urlVersion, attributes, transaction) ->
    @_log("UrlVersion.update urlId #{urlVersion.urlId}, urlGetId #{urlVersion.urlGetId}, sha1 #{urlVersion.sha1} -> #{attributes.sha1}, setting everything")
    Promise.all([
      models.UrlVersion.update(urlVersion, attributes, null, transaction: transaction)
      models.ArticleVersion.bulkUpdate({ stance: null, headlineStance: null }, { urlVersionId: urlVersion.id }, null, transaction: transaction)
    ])

  _destroyUrlVersion: (urlVersion, transaction) ->
    @_log("UrlVersion.destroy urlId #{urlVersion.urlId}, urlGetId #{urlVersion.urlGetId}, sha1 #{urlVersion.sha1}")
    models.ArticleVersion.destroy({ urlVersionId: urlVersion.id }, transaction: transaction)
      .then(-> models.UrlVersion.destroy({ id: urlVersion.id }, transaction: transaction))

  _merge: (urlId, url, urlGets, urlVersions) ->
    @_log("Reparsing #{urlGets.length} gets, overwriting #{urlVersions.length} parsed versions...")
    # Everything goes in a transaction: otherwise, we may be interrupted when
    # the database _looks_ fully updated but actually isn't.
    models.sequelize.transaction()
      .then (transaction) =>
        # Process the UrlGets synchronously; execute updates asynchronously.
        opChain = Promise.resolve(null)

        chainOp = (op, args...) =>
          opChain = opChain.then(=> @[op](args...))

        curUrlVersion = null # the head of the "fresh" list of UrlVersions
        previousUrlGet = null
        nextSavedUrlVersion = urlVersions.shift() # next in the "stale" list

        while (urlGet = urlGets.shift())?
          try
            newUrlVersion = @_urlGetToUrlVersion(urlGet, url)
          catch e
            return opChain.finally(-> transaction.rollback().throw(e))

          if newUrlVersion.urlGetId == nextSavedUrlVersion?.urlGetId
            if newUrlVersion.sha1 == curUrlVersion?.sha1
              # newUrlVersion is a duplicate.
              # That means nextSavedUrlVersion is a duplicate; delete it.
              chainOp('_destroyUrlVersion', nextSavedUrlVersion, transaction)
            else
              # overwrite existing version
              if newUrlVersion.sha1 == nextSavedUrlVersion.sha1
                chainOp('_updateUrlVersionParserVersion', nextSavedUrlVersion, newUrlVersion.parserVersion, transaction)
              else
                chainOp('_updateUrlVersion', nextSavedUrlVersion, newUrlVersion, transaction)
            nextSavedUrlVersion = urlVersions.shift()
          else if newUrlVersion.sha1 != curUrlVersion?.sha1
            # add new version
            newUrlVersion.millisecondsSincePreviousUrlGet = if previousUrlGet?
              urlGet.createdAt - previousUrlGet.createdAt
            else
              null
            chainOp('_createUrlVersion', newUrlVersion, urlGet.createdAt, transaction)
          else
            # nothing

          curUrlVersion = newUrlVersion
          previousUrlGet = urlGet

        opChain
          .then(transaction.commit.bind(transaction))
          .catch((e) -> transaction.rollback().throw(e))
