var Backbone = require('backbone');
var _ = require('underscore');
var $ = Backbone.$ = require('jquery');
var Claim = require('../models/claim.js');

module.exports = Backbone.Collection.extend({
  model: Claim,

  parse: function(response) {
    return response.claims;
  },

  filtered: function(regex) {
    return this.filter(function(claim) { return claim.searchableText().match(new RegExp(regex, 'gi')); });
  },

  comparator: function(c1, c2) {
    return c1.get('createdAt') < c2.get('createdAt') ? 1 : -1;
  }
});
