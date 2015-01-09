Backbone = require('backbone')

UserSubmittedClaim = require('../models/UserSubmittedClaim')

module.exports = class UserSubmittedClaims extends Backbone.Collection
  model: UserSubmittedClaim
  url: '/user-submitted-claims'
