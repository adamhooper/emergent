Sequelize = require('sequelize')
_ = require('lodash')

# Something on the Internet.
#
# A Url is just a web address; we store the stuff we find there in UrlGets and
# we store the info we parse from those in UrlVersions.
module.exports =
  columns:
    url:
      type: Sequelize.TEXT
      allowNull: false
      unique: true
      validate: { isUrl: true }

    cachedNSharesFacebook:
      type: Sequelize.BIGINT
      allowNull: false
      defaultValue: 0

    cachedNSharesGoogle:
      type: Sequelize.BIGINT
      allowNull: false
      defaultValue: 0

    cachedNSharesTwitter:
      type: Sequelize.BIGINT
      allowNull: false
      defaultValue: 0

  classMethods:
    findAllUnparsed: (options={}, queryOptions={}) ->
      options = _.extend({
        where: 'id NOT IN (SELECT DISTINCT "urlId" FROM "UrlVersion" WHERE "createdBy" IS NULL)'
        order: [[ 'url' ]]
      }, options)
      queryOptions = _.extend({}, queryOptions)
      @findAll(options, queryOptions)
