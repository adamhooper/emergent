module.exports =
  _: require('lodash')
  Promise: require('bluebird')
  models: require('../../data-store').models
  kueQueue: require('kue').createQueue()
