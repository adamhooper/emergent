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
        <ul className="articles">
          {this.props.claims.map(function(claim, i) {
            return (
              <li key={claim.id}>
                <article className="article">
                  <div className={'stance stance-' + claim.get('truthiness')}>
                    <span className="stance-value">{claim.truthinessText()}</span>
                  </div>
                  <div className="article-content">
                    <h4 className="article-title"><Link to="claim" params={{ slug: claim.get('slug') }}>{claim.get('headline')}</Link></h4>
                    <p className="article-description">Originated: <time datetime={claim.get('createdAt')}>{moment(claim.get('createdAt')).format('MMMM Do YYYY')}</time></p>
                  </div>
                </article>
              </li>
            );
          })}
        </ul>
      </div>
    );
  }
});
