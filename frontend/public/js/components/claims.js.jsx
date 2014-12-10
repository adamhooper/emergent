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
      filter: '',
      sort: 'Latest',
      stance: 'All'
    }
  },

  getDefaultProps: function() {
    return {
      sorting: [
        {
          'name': 'Latest'
        },
        {
          'name': 'Most Shared'
        }
      ],
      stance: [
        {
          'name': 'All'
        },
        {
          'name': 'True'
        },
        {
          'name': 'False'
        },
        {
          'name': 'Unverified'
        }
      ]
    };
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
    // Should combine the two, switch between for now
    var category = this.props.params.category;
    var claims;
    if (typeof category !== "undefined") {
      claims = this.props.claims.byCategory(category);
    } else {
      claims = this.props.claims.filtered(this.state.filter);
    }

    return claims;
  },

  formatNumber: function(str) {
    return new String(str).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  },

  render: function() {
    return (
      <div className="page">
        <div className="page-content">
          <div className="articles-holder">
            <nav className="articles-filtering">
              <ul className="articles-filtering-sort">
                {this.props.sorting.map(function(sorting, i) {
                  var classes = sorting.name === this.state.sort ? 'active' : null;
                  return (
                    <li key={i} className={classes}><a href="#">{sorting.name}</a></li>
                  );
                }.bind(this))}
              </ul>
             <ul className="articles-filtering-stance">
                {this.props.stance.map(function(stance, i) {
                  var classes = stance.name === this.state.stance ? 'active' : null;
                  return (
                    <li key={i} className={classes}><a href="#">{stance.name}</a></li>
                  );
                }.bind(this))}
              </ul>
            </nav>
            <ul className="articles">
              {this.filteredClaims().map(function(claim, i) {
                return (
                  <li key={claim.id}>
                    <article className="article article-preview">
                      <header className="article-header">
                        <div className={'stance stance-' + claim.get('truthiness')}>
                          <span className="stance-value">{claim.truthinessText()}</span>
                        </div>
                        <div className="article-meta">
                          <span className="article-category">World News – </span><time className="" datetime=""></time>
                          <span className="article-updated">Updated Nov 4</span>
                          {claim.get('nShares') ?
                          <span className="article-shares">Shares: {this.formatNumber(claim.get('nShares'))}</span>
                          : null}
                        </div>
                        <h2 className="article-title"><Link to="claim" params={{ slug: claim.get('slug') }}>{claim.get('headline')}</Link></h2>
                        <div className="article-byline">
                          <span className="article-source">Originating Source: </span>
                          <span className="article-originated"> Added <time datetime={claim.get('createdAt')}>{moment(claim.get('createdAt')).format('MMMM Do')}</time></span>
                        </div>
                      </header>
                      <p className="article-content">{claim.get('description')}</p>
                      <footer className="article-footer">

                      </footer>
                    </article>
                  </li>
                );
              }.bind(this))}
            </ul>
          </div>
          <nav className="page-navigation">
            <ul className="navigation navigation-page">
              <li><a href="#" class="navigation-link">Submit a claim</a></li>
              <li><a href="#" class="navigation-link">Sign up for our newsletter</a></li>
            </ul>
          </nav>
        </div>
      </div>
    );
  }
});
