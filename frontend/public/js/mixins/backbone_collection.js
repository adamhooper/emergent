/**
 * Ensure that changes to a components models/collections trigger reconciles
 */
var Backbone = require('backbone');
var _ = require('underscore');

module.exports = {
  _subscriptions: [],

  subscribeTo: function(collection) {
    this._subscriptions.push(collection);
  },

  componentDidMount: function() {
    _.each(this._subscriptions, function(bb) {
      if (bb instanceof Backbone.Collection) {
        this.bindCollection(bb);
      } else if (bb instanceof Backbone.Model) {
        this.bindModel(bb);
      }
    }, this);
  },
  
  bindCollection: function(coll) {
    coll.on('sync reset', function() {
      this.rebindModels();
      if (this.isMounted()) {
        this.forceUpdate();
      }
    }, this);
    this.rebindModels();
  },

  rebindModels: function() {
    _.each(this._subscriptions, function(coll) {
      _.each(coll.models, function(model) {
        this.bindModel(model);
      }, this);
    }, this);
  },

  bindModel: function(model) {
    model.off(null, null, this);
    model.on('add change remove', function() {
      if (this.isMounted()) {
        this.forceUpdate();
      }
    }, this);
  },

  componentWillUnmount: function() {
    _.each(this._subscriptions, function(coll) {
      coll.off(null, null, this);
      _.each(coll.models, function(model) {
        model.off(null, null, this);
      }, this);
    }, this);
  }
};
