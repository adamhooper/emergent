# For more information on configuration, check out:
# http://links.sailsjs.org/docs/config/connections

module.exports.connections =
  default: 'main'

  main:
    adapter: 'sails-mongo'
    database: 'truthmaker'
