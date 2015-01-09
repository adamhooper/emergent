Backbone = require('backbone')

module.exports = class UserSubmittedClaim extends Backbone.Model
  defaults:
    claim: ''
    url: ''
    spam: false
    archived: false
