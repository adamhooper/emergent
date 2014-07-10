crypto = require('crypto')

module.exports = class UrlVersionStore
  constructor: (options) ->
    throw 'Must pass options.urlVersions, a MongoDB Collection' if !options.urlVersions

    @urlVersions = options.urlVersions

    @urlVersions.createIndex({ urlId: 1, createdAt: -1 }, (->))
    @urlVersions.createIndex('sha1', { unique: true, dropDups: true }, (->))

  insert: (urlVersion, callback) ->
    object = {} # what we'll write to the collection

    for key in [ 'urlId', 'source', 'headline', 'byline', 'body', 'publishedAt' ]
      return callback(new Error('You must set urlVersion.urlId')) if key not of urlVersion
      object[key] = urlVersion[key]

    # Calculate sha1 of this url_version. When we try to insert() a record that
    # has a duplicate sha1, MongoDB will silently delete it because of our
    # unique index on the sha1 field.
    s = [
      urlVersion.urlId.toString()
      urlVersion.source
      urlVersion.headline
      urlVersion.byline
      urlVersion.publishedAt.toISOString()
      urlVersion.body
    ].join('\u0000')
    hash = crypto.createHash('sha1')
    hash.update(s, 'utf-8')
    object.sha1 = hash.digest()

    @urlVersions.insert(object, callback)
