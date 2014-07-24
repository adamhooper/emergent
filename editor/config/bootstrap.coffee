kue = require('kue')

module.exports.bootstrap = (next) ->
  global.kueQueue = kue.createQueue()
  next()
