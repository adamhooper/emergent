Promise = require('bluebird')
log = require('debug')('UserSubmittedClaimTracker')

models = require('../../data-store').models

# Finds UserSubmittedClaims with untracked URLs, and tracks them.
module.exports = class UserSubmittedClaimTracker
  constructor: (options) ->
    throw 'Must pass options.jobQueue, a JobQueue' if !options.jobQueue

    jobQueue = options.jobQueue
    @_queue = Promise.promisify(jobQueue.queue, jobQueue)

  trackRandomUntrackedUrl: (done) ->
    log('Fetching a random untracked UserSubmittedClaim to track')
    models.UserSubmittedClaim.find(where: { spam: false, urlId: null })
      .then (usc) =>
        if !usc?
          log('There are no untracked UserSubmittedClaims to track')
          return null

        log("Tracking UserSubmittedClaim #{usc.id} with URL #{usc.url}")

        models.Url.upsert({ url: usc.url }, null)
          .tap ([ url, isNew ]) => @_queue(url) if isNew
          .tap ([ url, isNew ]) ->
            models.UserSubmittedClaim.partialUpdate({ id: usc.id }, { urlId: url.id }, null)
          .tap(-> log('Done tracking.'))
      .then(-> null).nodeify(done)
