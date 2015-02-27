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
      truthiness: null,
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
      truthinesses: [
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

  setTruthinessFilter: function(truthiness) {
    this.setState({ truthiness: truthiness });
  },

  setSort: function(sort) {
    this.setState({ sort: sort });
  },

  filteredClaims: function() {
    // Should combine the two, switch between for now
    var category = this.props.params.category ? unescape(this.props.params.category) : null;
    var tag = this.props.params.tag ? unescape(this.props.params.tag) : null;
    if (category=='US') { category = 'U.S.'; } // ugh

    var Claims = this.props.claims;
    var claims = this.props.claims.models;

    if (this.state.search) {
      claims = Claims.bySearch(claims, this.state.search);
    }

    if (tag) {
      claims = Claims.byTag(claims, tag);
    }

    if (this.state.truthiness) {
      claims = Claims.byTruthiness(claims, this.state.truthiness);
    }

    if (category) {
      claims = Claims.byCategory(claims, category);
    } else {
      var hiddenCategoryIds = {};
      this.props.categories.forEach(function(c) {
        if (c.hidden) { hiddenCategoryIds[c.id] = true; }
      });
      claims = Claims.byAllButHiddenCategories(claims, hiddenCategoryIds);
    }

    if (this.state.sort) {
      claims = _.sortBy(claims, function(claim) { return claim.get(this.state.sort); }, this).reverse();
    } else {
      claims = _.sortBy(claims, function(claim) { return claim.get('publishedAt'); }, this).reverse();
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

  maybeRenderTrackedStance: function(claim, stance) {
    var n = claim.get('headlineStances')[stance];
    if (n) {
      var indicator = {
        'for': 'true',
        'against': 'false',
        'observing': 'observing'
      }[stance];
      return <span className="tracked-group">{n}<span className={"indicator indicator-" + indicator}></span></span>;
    } else {
      return "";
    }
  },

  render: function() {
    var filteredClaims = this.filteredClaims();
    return (
      <div className="page">
        <app.components.Header claims={this.props.claims} search={this.state.search || ''} category={this.heading()} categories={this.props.categories}/>
        <div className="page-content page-claims-parent">
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
             <ul className="navigation navigation-filtering navigation-filtering-truthiness">
                {this.props.truthinesses.map(function(truthiness, i) {
                  var classes = truthiness.value == this.state.truthiness ? 'active navigation-link' : 'navigation-link';
                  return (
                    <li key={i}><button onClick={this.setTruthinessFilter.bind(this, truthiness.value )} className={classes}>{truthiness.name}</button></li>
                  );
                }.bind(this))}
              </ul>
            </nav>
            <ul className="articles">
              {filteredClaims.length === 0 ?
                <li className="no-result">
                  <p>Sorry – no results match the selected criteria.</p>
                </li>
              : filteredClaims.slice(0, 30).map(function(claim, i) {
                return (
                  <li key={claim.id}>
                    <article className="article article-preview with-truthiness">
                      <header className="article-header">
                        <div className={'truthiness truthiness-' + claim.get('truthiness')}>
                          <span className="truthiness-value">{claim.truthinessText()}</span>
                        </div>
                        <div className="article-meta">
                          <span className="article-category">{claim.get('categories') && claim.get('categories').join(' - ')}</span>
                          {claim.get('nShares') ?
                          <span className="article-shares hidden-mobile"><span className="label">Shares:</span> {this.formatNumber(claim.get('nShares'))}</span>
                          : null}
                        </div>
                        <h2 className="article-title"><Link to="claim" params={{ slug: claim.get('slug') }}>{claim.get('headline')}</Link></h2>
                        <div className="article-byline">
                          {claim.get('originUrl') ?
                            <span className="article-source">Originating Source: {/*<span className="indicator indicator-true"> </span>*/}<a href={claim.get('originUrl')}>{claim.prettyUrl()}</a></span>
                          : null }
                          <span className="article-originated">Added <time dateTime={claim.get('publishedAt')}>{moment(claim.get('publishedAt')).format('MMM D')}</time></span>
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
                                <Link key={"article-tag-" + i} to="tag" params={{ tag: tag }}>{tag}</Link>
                              );
                            }.bind(this))}
                          </div>
                        : null}
                        <div className="article-tracked">
                          <span className="label">Tracked:</span>
                          {this.maybeRenderTrackedStance(claim, 'for')}
                          {this.maybeRenderTrackedStance(claim, 'against')}
                          {this.maybeRenderTrackedStance(claim, 'observing')}
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
              {/*<li>
                <app.components.Modal title="Submit a claim" trigger={<a href="#submit-a-claim" className="navigation-link">Submit a claim</a>}>
                  Lorem Ipsum
                </app.components.Modal>
                <p>Lorem ipsum dolor sit amet pro patria mori through our special tool.</p>
              </li>*/}
              <li>
                <strong>Sign up for our newsletter</strong>
                <p>Our weekly newsletter is the best way to get updates on the rumors we're tracking. We never sell or share your info.</p>
                <div id="mc_embed_signup">
                  <form action="//emergent.us2.list-manage.com/subscribe/post?u=657b595bbd3c63e045787f019&amp;id=80df098e56" method="post" id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" target="_blank">
                    <input type="email" name="EMAIL" id="mce-EMAIL" placeholder="Your Email"/>
                    <input type="hidden" name="b_657b595bbd3c63e045787f019_80df098e56" tabIndex="-1" value=""/>
                    <button type="submit" name="subscribe" className="button" id="mc-embedded-subscribe">Sign Up</button>
                  </form>
                </div>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    );
  }
});
