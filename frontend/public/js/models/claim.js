var Backbone = require('backbone');
var _ = require('underscore');
var $ = Backbone.$ = require('jquery');

module.exports = Backbone.Model.extend({

  stances: ['for', 'against', 'observing'],

  searchableText: function() {
    return this.get('headline') + " " + this.get('description');
  },

  truthinessText: function() {
    return this.get('truthiness')=='true' || this.get('truthiness')=='false' ? this.get('truthiness') : 'Unverified';
  },

  /* retrieve articles if we just have a base object */
  populate: function() {
    if (!this.get('articles')) {
      return $.when($.get(this.url() + '/articles')).done(function(articles) {
        this.set('articles', articles);
      }.bind(this));
    } else {
      return $.when();
    }
  },

  /* returns total shares, e.g. { for: nnnn, against: nnnn } */
  sharesByStance: function() {
    var shares = {};

    if (!this.get('articles')) {
      return shares;
    }

    _.each(this.get('articles'), function(article) {
      var stance = article.latestVersion.stance || '';
      if (!shares[stance]) shares[stance] = 0;

      _.each(_.values(article.nShares), function(n) {
        shares[stance] += n;
      });
    });
    return shares;
  },

  /* stance with most shares overall */
  mostShared: function() {
    return _.reduce(this.sharesByStance(), function(pair, num, stance) {
      return num > pair[1] ? [stance, num] : pair;
    }, ['', 0])[0];
  },

  /* returns sorted list of articles for a given stance
   *
   * If stance is empty, return all
   */
  articlesByStance: function(stance) {
    if (this.get('articles')) {
      var articles = _.filter(this.get('articles'), function(article) {
        return !stance || article.latestVersion.stance === stance;
      });
      return _.sortBy(articles, 'createdAt').reverse();
    } else {
      return [];
    }
  },

  startedTracking: function() {
    return this.get('createdAt');
  },

  originDate: function() {
    if (this.get('articles')) {
      return _.pluck(this.get('articles'), 'createdAt').sort()[0];
    }
  },

  domain: function(article) {
    return $('<a>', { href: article.url })[0].hostname;
  },

  nextByCategory: function() {
    if (!this.get('categories').length) {
      return null;
    }
    return _.last(_.sortBy(this.collection.filter(function(claim) {
      return _.contains(claim.get('categories'), this.get('categories')[0]) && claim.get('publishedAt') <= this.get('publishedAt') && claim.id != this.id;
    }, this), function(claim) {
      return claim.get('publishedAt');
    }, this));
  },

  prettyUrl: function(url) {
    if (!url) {
      var url = this.get('originUrl');
    }
    var match = url.match(/:\/\/(www[0-9]?\.)?(.[^/:]+)/i);
    if (match != null && match.length > 2 &&
        typeof match[2] === 'string' && match[2].length > 0) {
      return match[2];
    } else {
      return null;
    }
  }
});
