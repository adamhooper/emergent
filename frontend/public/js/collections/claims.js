var Backbone = require('backbone');
var _ = require('underscore');
var $ = Backbone.$ = require('jquery');
var Claim = require('../models/claim.js');

module.exports = Backbone.Collection.extend({
  model: Claim,

  parse: function(response) {
    return response.claims;
  },

  filtered: function(collection, regex) {
    return _.filter(collection, function(claim) { return claim.searchableText().match(new RegExp(regex, 'gi')); });
  },

  byCategory: function(collection, category) {
    return _.filter(collection, function(claim) { return _.contains(claim.get('categories'), category); });
  },

  byTag: function(collection, tag) {
    return _.filter(collection, function(claim) { return _.contains(claim.get('tags'), tag); });
  },

  byTruthiness: function(collection, truthiness) {
    if (truthiness == 'controversial') {
      return _.filter(collection, function(claim) {
        return claim.get('stances') && claim.get('stances')['for'] > 1 && claim.get('stances').against > 1;
      });
    } else {
      return _.filter(collection, function(claim) { return claim.get('truthiness')==truthiness; });
    }
  },

  tagsByFrequency: function() {
    return this.reduce(function(tags, claim) {
      _.each(claim.get('tags'), function(tag) { tags[tag] = isNaN(tags[tag]) ? 1 : tags[tag] + 1; });
      return tags;
    }, {});
  },

  // very simple logic for now
  trendingTags: function() {
    var tags = this.tagsByFrequency();
    return _.first(_.sortBy(_.filter(_.keys(tags), function(tag) {
      return tags[tag]>1;
    }), function(tag) {
      return -tags[tag];
    }), 5);
  }
});
