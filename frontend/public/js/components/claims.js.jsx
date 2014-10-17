/** @jsx React.DOM */

var React = require('react');
var BackboneCollection = require('../mixins/backbone_collection.js');
var Link = require('react-router').Link;
var _ = require('underscore');
var moment = require('moment');

module.exports = React.createClass({

  mixins: [BackboneCollection],

  getInitialState: function() {
    return {
      filter: ''
    }
  },

  componentWillMount: function() {
    this.subscribeTo(this.props.claims);
  },

  setFilter: function(e) {
    this.setState({
      filter: e.target.value
    });
  },

  filteredClaims: function() {
    return this.props.claims.filtered(this.state.filter);
  },

  formatNumber: function(str) {
    return new String(str).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  },

  render: function() {
    return (
      <div className="page">
        <div className="page-content">
          <div className="container">
            <div className="articles-search">
              <label for="claims-filter">Filter claims:</label>
              <input type="search" id="claims-filter" placeholder="Enter a word, phrase, etc." onChange={this.setFilter}/>
            </div>
            <ul className="articles">
              {this.filteredClaims().map(function(claim, i) {
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
                      {claim.get('nShares') ?
                        <footer className="article-footer">
                          <div className="shares">
                            <span className="shares-value">{this.formatNumber(claim.get('nShares'))}</span>
                            <span className="shares-label">shares</span>
                          </div>
                        </footer>
                      : null}
                    </article>
                  </li>
                );
              }.bind(this))}
            </ul>
          </div>
        </div>
      </div>
    );
  }
});
