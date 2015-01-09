Promise = require('bluebird')

App = require('../../app')
UserSubmittedClaims = require('../../collections/UserSubmittedClaims')
UserSubmittedClaimListLayout = require('../../views/UserSubmittedClaimListLayout')

module.exports =
  go: ->
    claims = new UserSubmittedClaims
    Promise.resolve(claims.fetch())
      .then ->
        layout = UserSubmittedClaimListLayout.forCollectionInRegion(claims, App.mainRegion)
