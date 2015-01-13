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
      sort: null,
      stance: null,
      search: this.props.query.search
    }
  },

  componentWillReceiveProps: function(props) {
    this.setState({ search: props.query.search });
  },

  getDefaultProps: function() {
    return {
      sortings: [
        {
          'name': 'Latest'
        },
        {
          'name': 'Most Shared',
          'value': 'nShares'
        }
      ],
      stances: [
        {
          'name': 'All',
          'value': null
        },
        {
          'name': 'True',
          'value': 'true'
        },
        {
          'name': 'False',
          'value': 'false'
        },
        {
          'name': 'Unverified',
          'value': 'unknown'
        },
        {
          'name': 'Controversial',
          'value': 'controversial'
        }
      ]
    };
  },

  componentWillMount: function() {
    this.subscribeTo(this.props.claims);
  },

  setStanceFilter: function(stance) {
    this.setState({ stance: stance });
  },

  setSort: function(sort) {
    this.setState({ sort: sort });
  },

  filteredClaims: function() {
    // Should combine the two, switch between for now
    var category = this.props.params.category ? unescape(this.props.params.category) : null;
    var tag = this.props.params.tag ? unescape(this.props.params.tag) : null;
    if (category=='US') { category = 'U.S.'; } // ugh

    var claims = this.props.claims.models;
    if (this.state.search) {
      claims = this.props.claims.filtered(claims, this.state.search);
    } else if (category) {
      claims = this.props.claims.byCategory(claims, category);
    } else if (tag) {
      claims = this.props.claims.byTag(claims, tag);
    }

    if (this.state.stance) {
      claims = this.props.claims.byStance(claims, this.state.stance);
    }

    if (this.state.sort) {
      claims = _.sortBy(claims, function(claim) { return claim.get(this.state.sort); }, this).reverse();
    }
    return claims;
  },

  heading: function() {
    if (this.state.search) {
      return 'Search results: ' + unescape(this.state.search);
    }
    if (this.props.params.category) {
      return unescape(this.props.params.category);
    }
    if (this.props.params.tag) {
      return unescape(this.props.params.tag);
    }
    return 'Home';
  },

  formatNumber: function(str) {
    return new String(str).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  },

  render: function() {
    return (
      <div className="page">
        <app.components.Header claims={this.props.claims} search={this.state.search || ''} category={this.heading()}/>
        <div className="page-content">
          <div className="articles-holder section-with-sidebar">
            <nav className="articles-filtering">
              <ul className="navigation navigation-filtering navigation-filtering-sort">
                {this.props.sortings.map(function(sorting, i) {
                  var classes = sorting.value == this.state.sort ? 'active navigation-link' : 'navigation-link';
                  return (
                    <li key={i}><button onClick={this.setSort.bind(this, sorting.value)} className={classes}>{sorting.name}</button></li>
                  );
                }.bind(this))}
              </ul>
             <ul className="navigation navigation-filtering navigation-filtering-stance">
                {this.props.stances.map(function(stance, i) {
                  var classes = stance.value == this.state.stance ? 'active navigation-link' : 'navigation-link';
                  return (
                    <li key={i}><button onClick={this.setStanceFilter.bind(this, stance.value )} className={classes}>{stance.name}</button></li>
                  );
                }.bind(this))}
              </ul>
            </nav>
            <ul className="articles">
              {this.filteredClaims().map(function(claim, i) {
                return (
                  <li key={claim.id}>
                    <article className="article article-preview with-stance">
                      <header className="article-header">
                        <div className={'stance stance-' + claim.get('truthiness')}>
                          <span className="stance-value">{claim.truthinessText()}</span>
                        </div>
                        <div className="article-meta">
                          <span className="article-category">{claim.get('categories') && claim.get('categories').join(' - ')}</span>
                          {claim.get('nShares') ?
                          <span className="article-shares hidden-mobile"><span className="label">Shares:</span> {this.formatNumber(claim.get('nShares'))}</span>
                          : null}
                        </div>
                        <h2 className="article-title"><Link to="claim" params={{ slug: claim.get('slug') }}>{claim.get('headline')}</Link></h2>
                        <div className="article-byline">
                          <span className="article-source">Originating Source: <span className="indicator indicator-true"> </span><a href="#">The Guardian</a></span>
                          <span className="article-originated">Added <time datetime={claim.get('createdAt')}>{moment(claim.get('createdAt')).format('MMM D')}</time></span>
                          <span className="article-shares hidden-desktop"><span className="label">Shares:</span> {this.formatNumber(claim.get('nShares'))}</span>
                        </div>
                      </header>
                      <p className="article-content">{claim.get('description')}</p>
                      <footer className="article-footer">
                        {claim.get('tags').length > 0 ?
                          <div className="article-tags">
                            <span className="label">Tagged:</span>
                            {claim.get('tags').map(function(tag, i) {
                              return (
                                <Link to="tag" params={{ tag: tag }}>{tag}</Link>
                              );
                            }.bind(this))}
                          </div>
                        : null}
                        <div className="article-tracked">
                          <span className="label">Tracked:</span>
                          {claim.get('stances')['for'] ? <span className="tracked-group">{claim.get('stances')['for']}<span className="indicator indicator-true"></span></span> : null}
                          {claim.get('stances')['against'] ? <span className="tracked-group">{claim.get('stances')['against']}<span className="indicator indicator-false"></span></span> : null}
                          {claim.get('stances')['observing'] ? <span className="tracked-group">{claim.get('stances')['observing']}<span className="indicator indicator-unknown"></span></span> : null}
                        </div>
                      </footer>
                    </article>
                  </li>
                );
              }.bind(this))}
            </ul>
          </div>
          <nav className="page-navigation">
            <ul className="navigation navigation-page">
              <li>
                <a href="#" className="navigation-link">Submit a claim</a>
                <p>Lorem ipsum dolor sit amet pro patria mori through our special tool.</p>
              </li>
              <li>
                <a href="http://eepurl.com/3mb9T" className="navigation-link">Sign up for our newsletter</a>
                <p>Our weekly newsletter is the best way to get updates on the rumors we're tracking. We never sell or share your info.</p>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    );
  }
});
