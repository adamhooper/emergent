var Backbone = require('backbone');
var _ = require('underscore');
var $ = Backbone.$ = require('jquery');

module.exports = Backbone.Model.extend({

  stances: ['for', 'against', 'observing'],

  truthinessText: function() {
    return this.get('truthiness')=='true' || this.get('truthiness')=='false' ? 'Confirmed ' + this.get('truthiness') : 'Unverified';
  },

  /* retrieve articles and timeslices if we just have a base object */
  populate: function() {
    if (!this.get('articles')) {
      return $.when($.get(this.url() + '/articles'), $.get(this.url() + '/timeslices')).done(function(articles, slices) {
        this.set('articles', articles[0]);
        this.setIncrementalSlices(slices[0]);
      }.bind(this));
    } else {
      return $.when();
    }
  },

  /* sets each slices to incremental share increase */
  setIncrementalSlices: function(slices) {
    var articles = {};
    _.each(slices, function(slice, time) {
      _.each(slice.articles, function(article, articleId) {
        var last = articles[articleId];
        var current = _.clone(article.shares);
        _.keys(current).forEach(function(provider) {
          if (last && current[provider]*2 > last[provider]) {
            article.shares[provider] = _.max([0, current[provider] - last[provider]]);
          }
        });
        articles[articleId] = current;
      }, this);
    }, this);
    this.set('slices', slices);
  },

  /* returns total shares, e.g. { for: nnnn, against: nnnn } */
  sharesByStance: function() {
    var shares = {}
    if (!this.get('slices') || !this.get('slices').length) {
      return {};
    }
    _.each(this.get('slices'), function(slice) {
      _.each(slice.articles, function(shared, articleId) {
        var bestStance = this.bestStance(shared);
        if (_.contains(this.stances, bestStance)) {
          shares[bestStance] = _.reduce(shared.shares, function(s, n) { return s + n; }, shares[bestStance]||0);
        }
      }, this);
    }, this);
    return shares;
  },

  /* stance with most shares overall */
  mostShared: function() {
    return _.reduce(this.sharesByStance(), function(pair, num, stance) {
      return num > pair[1] ? [stance, num] : pair;
    }, ['', 0])[0];
  },

  /* returns sorted list of articles for a given stance, including shares and stance attribtes. if stance is empty, return all */
  articlesByStance: function(stance) {

    if (!stance) {
      return _.sortBy(_.reduce(this.articlesByStance('for').concat(this.articlesByStance('against')).concat(this.articlesByStance('observing')), function(articles, article) {
        var entry = _.findWhere(articles, { id: article.id });
        if (entry) { // combine articles with changed stance
          if (article.shares > entry.shares) {
            entry.stance = article.stance; // record stance that got most shares
          }
          entry.shares += article.shares;
        } else {
          articles.push(article);
        }
        return articles;
      }, [], this), 'shares').reverse();
    }

    var articles = {};
    if (!this.get('slices') || !this.get('slices').length) {
      return [];
    }
    _.each(this.get('slices'), function(slice) {
      _.each(slice.articles, function(shared, articleId) {
        var bestStance = this.bestStance(shared);
        var article = articles[articleId] || _.clone(_.findWhere(this.get('articles'), { id: articleId }));
        if (bestStance && article.stance != bestStance) {
          if (article.stance) {
            article.revised = bestStance;
          } else {
            article.stance = bestStance;
          }
        }
        if (bestStance == stance) {
          article.shares = _.reduce(shared.shares, function(s, n) { return s + n; }, article.shares||0);
        }
        articles[articleId] = article;
      }, this);
    }, this);
    return _.sortBy(_.filter(articles, function(article) { return article.shares; }), 'shares').reverse();
  },

  /* returns list of slices, e.g. [{ time: Date, against: nnn, for: nnn }, ... ] */
  aggregateSlices: function() {
    var s = {};
    if (!this.get('slices') || !this.get('slices').length) {
      return [];
    }
    return _.map(this.get('slices'), function(slice) {
      s = _.reduce(slice.articles, function(shares, article) {
        var bestStance = this.bestStance(article);
        if (_.contains(this.stances, bestStance)) {
          shares[bestStance] = _.reduce(article.shares, function(s, n) { return s + n; }, shares[bestStance]||0);
        }
        return shares;
      }, _.defaults({ time: new Date(slice.end) }, s), this);
      return s;
    }, this);
  },

  slicesByArticle: function(articleId) {
    if (!this.get('slices') || !this.get('slices').length) {
      return [];
    }
    var slices = [];
    _.each(this.get('slices'), function(slice) {
      var current = slice.articles[articleId];
      if (current) {
        var last = _.last(slices);
        if (last && last.stance==(current.stance||last.stance) && last.headlineStance==(current.headlineStance||last.headlineStance)) {
          last.shares = _.reduce(last.shares, function(shares, count, service) {
            shares[service] = count + (current.shares[service]||0);
            return shares;
          }, {});
        } else {
          slices.push(_.defaults({ end: slice.end }, current));
        }
      }
    });
    return slices;
  },

  startedTracking: function() {
    return this.get('createdAt');
  },

  originDate: function() {
    if (this.get('articles')) {
      return _.pluck(this.get('articles'), 'publishedAt').sort()[0];
    }
  },

  /* returns count by stance for articleId, e.g. { for: nnn, against: nnn... } */
  sharesByArticle: function(articleId) {
    return _.reduce(this.get('slices'), function(shares, slice) {
      var stance = slice.articles[articleId] && this.bestStance(slice.articles[articleId]);
      if (slice.articles[articleId] && slice.articles[articleId].shares && _.contains(this.stances, stance)) {
        shares[stance] = _.reduce(slice.articles[articleId].shares, function(shares, count) { return shares + count; }, shares[stance]||0);
      }
      return shares;
    }, {}, this);
  },

  /* returns total for claim { facebook: nnn, google: nnn,... } to make these totals line up, only count ones with relevant stances */
  sharesByProvider: function() {
    return _.reduce(this.get('slices'), function(shares, slice) {
      return _.reduce(slice.articles, function(shares, article) {
        if (_.contains(this.stances, this.bestStance(article))) {
          shares = _.reduce(article.shares, function(shares, count, provider) {
            shares[provider] = (shares[provider]||0) + count;
            return shares;
          }, shares);
        }
        return shares;
      }, shares, this);
    }, {}, this);
  },

  /* stance of an article when we must pick one */
  bestStance: function(article) {
    return article.headlineStance!='for' && article.headlineStance!='against' && _.contains(this.stances, article.stance) ? article.stance : article.headlineStance;
  },

  domain: function(article) {
    return $('<a>', { href: article.url })[0].hostname;
  }
});
