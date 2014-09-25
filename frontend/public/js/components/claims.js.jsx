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
      <div className="page">
        <div className="page-content">
          <div className="container">
            <ul className="articles">
              {this.props.claims.map(function(claim, i) {
                return (
                  <li key={claim.id}>
                    <article className="article">
                      <header className="article-header">
                        <div className={'stance stance-' + claim.get('truthiness')}>
                          <span className="stance-value">{claim.truthinessText()}</span>
                        </div>
                      </header>
                      <div className="article-content">
                        <h4 className="article-title"><Link to="claim" params={{ slug: claim.get('slug') }}>{claim.get('headline')}</Link></h4>
                        <p className="article-description">Originated: <time datetime={claim.get('createdAt')}>{moment(claim.get('createdAt')).format('MMMM Do YYYY')}</time></p>
                      </div>
                      {claim.get('shares') ?
                        <footer className="article-footer">
                          <div className="shares">
                            <span className="shares-value">0</span>
                            <span className="shares-label">shares</span>
                          </div>
                        </footer>
                      : null}
                    </article>
                  </li>
                );
              })}
            </ul>
          </div>
        </div>
      </div>
    );
  }
});
