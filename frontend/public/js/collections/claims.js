var Backbone = require('backbone');
var _ = require('underscore');
var $ = Backbone.$ = require('jquery');
var Claim = require('../models/claim.js');

module.exports = Backbone.Collection.extend({
  model: Claim,

  parse: function(response) {
    return response.claims;
  },

  bySearch: function(collection, regex) {
    return _.filter(collection, function(claim) { return claim.searchableText().match(new RegExp(regex, 'gi')); });
  },

  byCategory: function(collection, category) {
    return _.filter(collection, function(claim) { return _.contains(claim.get('categories'), category); });
  },

  byAllWithMaxPerCategory: function(collection, nPerCategory) {
    var categoryCounts = {};

    return _.filter(collection, function(claim) {
      // Increment categoryCounts for this claim's categories
      claim.get('categories').forEach(function(category) {
        if (category in categoryCounts) {
          categoryCounts[category] += 1;
        } else {
          categoryCounts[category] = 1;
        }
      });
      // Show the claim if there are categories worth showing it for
      return claim.get('categories').some(function(category) {
        return categoryCounts[category] <= nPerCategory;
      });
    });
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
