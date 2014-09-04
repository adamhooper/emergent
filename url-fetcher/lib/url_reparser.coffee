Promise = require('bluebird')
_ = require('lodash')

models = require('../../data-store').models

module.exports = class UrlReparser
  constructor: (options) ->
    throw 'Must pass options.htmlParser, an HtmlParser' if 'htmlParser' not of options

    @_parse = options.htmlParser.parse.bind(options.htmlParser)
    @_log = options?.log ? console.log

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
      models.UrlGet.findAll(where: { urlId: urlId }, order: [ [ 'createdAt' ] ])
      models.UrlVersion.findAll(where: { urlId: urlId, urlGetId: { ne: null }, parserVersion: { ne: null } }, order: [ [ 'createdAt' ] ])
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
    @_log("UrlVersion.create urlId #{urlVersion.urlId}, sha1 #{urlVersion.sha1}, date #{createdAt.toISOString()}")
    models.UrlVersion.create(urlVersion, null, createdAt: createdAt, transaction: transaction)
      .then((x) -> x.id)
      .then (urlVersionId) ->
        models.Article.findAll({ where: { urlId: urlVersion.urlId } }, transaction: transaction)
          .map((article) -> models.ArticleVersion.create({ urlVersionId: urlVersionId, articleId: article.id }, null, transaction: transaction))

  _updateUrlVersionParserVersion: (urlVersion, parserVersion, transaction) ->
    @_log("UrlVersion.update (urlId #{urlVersion.urlId}, sha1 #{urlVersion.sha1}, parserVersion #{parserVersion}")
    models.UrlVersion.update(urlVersion, { parserVersion: parserVersion }, null, transaction: transaction)

  _updateUrlVersion: (urlVersion, attributes, transaction) ->
    @_log("UrlVersion.update urlId #{urlVersion.urlId}, sha1 #{urlVersion.sha1} (full) rewrite")
    Promise.all([
      models.UrlVersion.update(urlVersion, attributes, null, transaction: transaction)
      models.ArticleVersion.bulkUpdate({ stance: null, headlineStance: null }, { urlVersionId: urlVersion.id }, null, transaction: transaction)
    ])

  _merge: (urlId, url, urlGets, urlVersions) ->
    @_log("Reparsing #{urlGets.length} gets, overwriting #{urlVersions.length} parsed versions...")
    # Everything goes in a transaction: otherwise, we may be interrupted when
    # the database _looks_ fully updated but actually isn't.
    models.sequelize.transaction()
      .then (transaction) =>
        # Process the UrlGets synchronously; execute updates asynchronously.
        opChain = Promise.resolve(null)

        curUrlVersion = null # the head of the "fresh" list of UrlVersions
        nextSavedUrlVersion = urlVersions.shift() # next in the "stale" list

        while (urlGet = urlGets.shift())?
          newUrlVersion = @_urlGetToUrlVersion(urlGet, url)

          if newUrlVersion.urlGetId == nextSavedUrlVersion?.urlGetId
            # re-save existing version
            # Note we do this commands synchronously: a cheap hack to make sure the
            # variables don't change beneath us, and it's okay because we can run
            # these queries in any order as long as they're all committed together
            if newUrlVersion.sha1 == nextSavedUrlVersion.sha1
              opChain = opChain.then(@_updateUrlVersionParserVersion(nextSavedUrlVersion, newUrlVersion.parserVersion, transaction))
            else
              opChain = opChain.then(@_updateUrlVersion(nextSavedUrlVersion, newUrlVersion, transaction))
            nextSavedUrlVersion = urlVersions.shift()
          else if newUrlVersion.sha1 != curUrlVersion?.sha1
            # add new version
            # Note we do this command synchronously: a cheap hack to make sure the
            # variables don't change beneath us, and it's okay because we can run
            # these queries in any order as long as they're all committed together
            opChain = opChain.then(@_createUrlVersion(newUrlVersion, urlGet.createdAt, transaction))
          else
            # nothing

          curUrlVersion = newUrlVersion

        opChain.then(transaction.commit.bind(transaction))
