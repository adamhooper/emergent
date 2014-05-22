module.exports.bootstrap = (next) ->
  ObjectIdRegex = /^[a-z0-9]{24}$/

  isObjectId = (x) -> ObjectIdRegex.test(x.toString?() || '')

  # Allow ObjectID. These fixes should come into Sails eventually.
  require('../node_modules/sails/node_modules/waterline/lib/waterline/utils/types').push('objectid')
  require('../node_modules/sails/node_modules/anchor/index').define('objectid', isObjectId)

  next()
