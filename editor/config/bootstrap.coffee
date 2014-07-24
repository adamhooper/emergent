kue = require('kue')

global.models = require('../../data-store').models

module.exports.bootstrap = (next) ->
  global.kueQueue = kue.createQueue()
  next()
