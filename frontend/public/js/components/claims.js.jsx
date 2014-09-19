/** @jsx React.DOM */

var React = require('react');
var BackboneCollection = require('../mixins/backbone_collection.js');
var Link = require('react-router').Link;
var _ = require('underscore');
var moment = require('moment');

module.exports = React.createClass({

  mixins: [BackboneCollection],

  componentWillMount: function() {
    this.subscribeTo(this.props.claims);
  },

  render: function() {
    return (
      <div className="container">
        <ul>
          {this.props.claims.models.map(function(claim, i) {
            return (
              <li key={claim.id}>
                <Link to="claim" params={{ slug: claim.get('slug') }}>{claim.get('headline')}</Link>
              </li>
            );
          })}
        </ul>
      </div>
    );
  }
});
