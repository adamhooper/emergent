JobQueue = require('../../job-queue')

module.exports =
  _: require('lodash')
  Promise: require('bluebird')
  models: require('../../data-store').models
  urlJobQueue: new JobQueue(key: 'urls')
