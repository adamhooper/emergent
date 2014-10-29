/** @jsx React.DOM */

var React = require('react');
var BackboneCollection = require('../mixins/backbone_collection.js');
var Barchart = require('./bar_chart.js.jsx');
var Link = require('react-router').Link;
var _ = require('underscore');
var moment = require('moment');

module.exports = React.createClass({

  mixins: [BackboneCollection],

  getInitialState: function() {
    return {
      filter: null,
      filterHeights: { 'for': 1, against: 1, observing: 1 }
    };
  },

  componentWillMount: function() {
    var claim = this.props.claims.findWhere({ slug: this.props.params.slug });
    this.subscribeTo(claim);
    this.setState({
      claim: claim,
      populated: false
    });
    claim.populate().done(function() {
      this.setState({ populated: true });
    }.bind(this));
    window.claim = claim;
  },

  componentDidMount: function() {
    this.setState({ barChartWidth: 926 });
    addthis.toolbox('.addthis_toolbox');
  },

  setFilter: function(filter) {
    if (filter) {
      var heights = { 'for': 0, against: 0, observing: 0 };
      heights[filter] = 1;
      this.setState({ targetHeights: heights });
    } else {
      this.setState({ targetHeights: { 'for': 1, against: 1, observing: 1 } });
    }
    this.setState({
      filter: filter,
      animate: setInterval(this.animateHeights, 20)
    });
  },

  animateHeights: function() {
    if (!this.isMounted()) {
      clearInterval(this.state.animate);
      return;
    }
    var keepAnimating = false;
    filterHeights = this.state.filterHeights;
    _.each(['for', 'against', 'observing'], function(stance) {
      if (this.state.targetHeights[stance] != filterHeights[stance]) {
        if (Math.abs(filterHeights[stance] - this.state.targetHeights[stance]) > .2) {
          filterHeights[stance] += this.state.targetHeights[stance] > filterHeights[stance] ? .06 : -.06;
          keepAnimating = true;
        } else if (Math.abs(filterHeights[stance] - this.state.targetHeights[stance]) > .01) {
          filterHeights[stance] += this.state.targetHeights[stance] > filterHeights[stance] ? .02 : -.02;
          keepAnimating = true;
        } else {
          filterHeights[stance] = this.state.targetHeights[stance];
        }
      }
    }, this);
    this.setState({ filterHeights: filterHeights });
    if (!keepAnimating) {
      clearInterval(this.state.animate);
    }
  },

  formatNumber: function(str) {
    return new String(str).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  },

  truncateString: function(str) {
    return str.length > 70 ? str.substring(0, str.lastIndexOf(' ', 70)) + '...' : str;
  },

  render: function() {
    var claim = this.state.claim;
    var shares = claim.sharesByStance();
    var colors = [
      '#7ecc76',
      '#dd5b53',
      '#f9be58'
    ];
    var totalShares = _.reduce(shares, function(sum, num) { return sum + num; }, 0);

    if (this.state.populated) {
      var slices = claim.aggregateSlices().slice(0, 18);
      var data = slices.reduce(function(series, slice) {
        series[0].push((slice.for||0) * this.state.filterHeights.for);
        series[1].push((slice.against||0) * this.state.filterHeights.against);
        series[2].push((slice.observing||0) * this.state.filterHeights.observing);
        return series;
      }.bind(this), [[],[],[]]);

      // find x-axis labels
      var skips = 3;
      if (slices.length > 2 * this.state.barChartWidth / 100) { skips = 6; }
      if (slices.length > 4 * this.state.barChartWidth / 100) { skips = 12; }
      var labels = slices.map(function(slice, i) {
        return i%skips ? '' : moment(slice.time).format('MMM Do, YYYY').toUpperCase();
      });
      labels[0] = labels[1] = labels[labels.length - 1] = labels[labels.length - 2] = '';
      // find y-axis labels
      var highest = _.max(data.reduce(function(heights, line) {
        line.forEach(function(amount, i) {
          heights[i] = (heights[i]||0) + amount;
        });
        return heights;
      }, []));
      var steps = slices.length ? Math.pow(10, Math.floor(Math.log(highest)/Math.log(10) - 0.15)) : 0;
      var ylabels = _.range(steps, highest, steps);
      if (ylabels.length > 8) {
        ylabels = ylabels.filter(function(a,i) { return i%2; });
      }
      ylabels = _.reduce(ylabels, function(ylabels, y) {
        return ylabels.concat({ y: y, label: this.formatNumber(y) });
      }, [{ y:0, label: 'Total shares' }], this);

      // place callout for confirmation
      var callout;
      if (claim.get('truthinessDate')) {
        callout = {
          position: _.find(_.range(slices.length), function(s) { return slices[s].time > new Date(claim.get('truthinessDate')); }),
          text: [
            moment(claim.get('truthinessDate')).format('MMM Do').toUpperCase(),
            'CONFIRMED',
            claim.get('truthiness').toUpperCase()
          ]
        };
      }
      window.callout = callout;
    }

    var mostShared = claim.mostShared(),
      startedTracking = claim.startedTracking(),
      originDate = claim.originDate(),
      truthinessDate = claim.get('truthinessDate');

    return (

      <div className="page page-claim">
        <div className="page-header">
          <div className="container">

            <div className="section">
              <header className="section-header">
                <h1 className="page-title">{claim.get('headline')}</h1>
                <p>{claim.get('description')}</p>
                {claim.get('origin') ? <p className="tracking"><strong>Originated: </strong>{moment(originDate).format('MMM D, YYYY H:mm') + ' (' + moment(originDate).fromNow() + ')'} {claim.get('originUrl') ? <a href={claim.get('originUrl')} target="_blank">View Article</a> : null}<br />{claim.get('origin')}</p> : null}
                <p className="tracking"><strong>Started Tracking:</strong> {moment(startedTracking).format('MMM D, YYYY H:mm') + ' (' + moment(startedTracking).fromNow() + ')'}</p>
                {claim.get('truthiness') ? <p className={"tracking tracking-" + claim.get('truthiness')}><strong>Confirmed: </strong>{moment(truthinessDate).format('MMM D, YYYY H:mm') + ' (' + moment(truthinessDate).fromNow() + ')'} {claim.get('truthinessUrl') ? <a href={claim.get('truthinessUrl')} target="_blank">View Article</a> : null}<br />{claim.get('truthinessDescription')}</p> : null}
              </header>
              <div className="page-meta">

                <div className={'status status-' + claim.get('truthiness')}>
                  <span className="status-label">Claim State</span>
                  <span className="status-value">{claim.truthinessText()}</span>
                </div>
                <div className={'status status-' + (mostShared ? mostShared : '')}>
                  <span className="status-label">Most Shared Claim</span>
                  <span className="status-value">{mostShared ? mostShared : ''}</span>
                </div>

                { this.state.populated ?
                <div className="meta">
                  <div className="shares">
                    <span className="shares-value">{claim.articlesByStance().length}</span>
                    <span className="shares-label">sources</span>
                  </div>
                  <div className="shares">
                    <span className="shares-value">{this.formatNumber(claim.get('nShares'))}</span>
                    <span className="shares-label">shares</span>
                  </div>
                  <ul className="social">
                  {_.map(claim.sharesByProvider(), function(shares, provider) {
                      return (
                        <li>
                          <span className={'icon icon-' + provider}>{provider}</span>
                          <span className="social-value">{Math.round(shares / totalShares * 100)}%</span>
                        </li>
                      );
                    }, this)}
                  </ul>
                </div>
                : null }
              </div>
            </div>

            <section className="cards cards-section">
              <div className={'card-categories card-categories-' + _.filter(claim.sharesByStance(), function(c) { return c; }).length}>
                { claim.articlesByStance('for').length > 0 ?
                  <div onClick={this.setFilter.bind(this, 'for')} className={'card card-category card-category-for' + (this.state.filter === 'for' ? ' is-selected' : '')}>
                    <div className="card-header">
                      <p className="card-title">For{claim.get('truthiness') === 'true' ? <span className="icon icon-confirmed">Confirmed</span> : null}</p>
                      <div className="card-meta">
                        <p className="sources">{claim.articlesByStance('for').length} sources</p>
                        <div className="shares">
                          <span className="shares-value">{mostShared === 'for' ? <span className="icon icon-most-shared"/> : null}{shares.for ? this.formatNumber(shares.for) : 0}</span>
                          <span className="shares-label">shares</span>
                        </div>
                      </div>
                    </div>
                    <div className="card-content">
                      <p className="article-source-title">Top Source</p>
                      {_.first(claim.articlesByStance('for'), 1).map(function(article) {
                        return (
                          <article className="article article-source" key={article.id}>
                            <h4 className="article-title">{article.source} - <time dateTime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                            <p className="article-description"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{this.truncateString(article.headline)}</Link></p>
                            <p><strong>{this.formatNumber(article.shares) + ' shares'}</strong></p>
                          </article>
                        )
                      }, this)}
                    </div>
                  </div>
                  : null
                }
                { claim.articlesByStance('against').length > 0 ?
                  <div onClick={this.setFilter.bind(this, 'against')} className={'card card-category card-category-against' + (this.state.filter === 'against' ? ' is-selected' : '')}>
                    <div className="card-header">
                      <p className="card-title">Against{claim.get('truthiness') === 'false' ? <span className="icon icon-confirmed">Confirmed</span> : null}</p>
                      <div className="card-meta">
                        <p className="sources">{claim.articlesByStance('against').length} sources</p>
                        <div className="shares">
                          <span className="shares-value">{mostShared === 'against' ? <span className="icon icon-most-shared"/> : null}{shares.against ? this.formatNumber(shares.against) : 0}</span>
                          <span className="shares-label">shares</span>
                        </div>
                      </div>
                    </div>
                    <div className="card-content">
                      <p className="article-source-title">Top Source</p>
                      {_.first(claim.articlesByStance('against'), 1).map(function(article) {
                        return (
                          <article className="article article-source" key={article.id}>
                            <h4 className="article-title">{article.source} - <time dateTime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                            <p className="article-description"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{this.truncateString(article.headline)}</Link></p>
                            <p><strong>{this.formatNumber(article.shares) + ' shares'}</strong></p>
                          </article>
                        )
                      }, this)}
                    </div>
                  </div>
                  : null
                }
                { claim.articlesByStance('observing').length > 0 ?
                  <div onClick={this.setFilter.bind(this, 'observing')} className={'card card-category card-category-observing' + (this.state.filter === 'observing' ? ' is-selected' : '')}>
                    <div className="card-header">
                      <p className="card-title">Observing</p>
                      <div className="card-meta">
                        <p className="sources">{claim.articlesByStance('observing').length} sources</p>
                        <div className="shares">
                          <span className="shares-value">{mostShared === 'observing' ? <span className="icon icon-most-shared"/> : null}{shares.observing ? this.formatNumber(shares.observing) : 0}</span>
                          <span className="shares-label">shares</span>
                        </div>
                      </div>
                    </div>
                    <div className="card-content">
                      <p className="article-source-title">Top Source</p>
                      {_.first(claim.articlesByStance('observing'), 1).map(function(article) {
                        return (
                          <article className="article article-source" key={article.id}>
                            <h4 className="article-title">{article.source} - <time dateTime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                            <p className="article-description"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{this.truncateString(article.headline)}</Link></p>
                            <p><strong>{this.formatNumber(article.shares) + ' shares'}</strong></p>
                          </article>
                        )
                      }, this)}
                    </div>
                  </div>
                  : null
                }
              </div>
            </section>
          </div>
        </div>

        {this.state.populated ?
          <div className="page-content">
            <div className="container">
              <nav>
                <ul className="filters">
                  <li><button onClick={this.setFilter.bind(this, null)} className={'filter filter-category filter-category-all' + (!this.state.filter ? ' is-selected' : '')}>All Shares</button></li>
                  { claim.articlesByStance('for').length > 0 ? <li><button onClick={this.setFilter.bind(this, 'for')} className={'filter filter-category filter-category-for' + (this.state.filter === 'for' ? ' is-selected' : '')}>For</button></li> : null }
                  { claim.articlesByStance('against').length > 0 ? <li><button onClick={this.setFilter.bind(this, 'against')} className={'filter filter-category filter-category-against' + (this.state.filter === 'against' ? ' is-selected' : '')}>Against</button></li> : null }
                  { claim.articlesByStance('observing').length > 0 ? <li><button onClick={this.setFilter.bind(this, 'observing')} className={'filter filter-category filter-category-observing' + (this.state.filter === 'observing' ? ' is-selected' : '')}>Observing</button></li> : null }
                </ul>
              </nav>
              <section className="section">
                <h3 className="section-title">Shares Over Time</h3>
                <div className="section-content">
                  <Barchart width={this.state.barChartWidth - 120} height={200} ref="chart" marginBottom={20} marginTop={callout ? 75: 10} marginLeft={100} marginRight={20} ylabels={ylabels} labels={labels} series={data} colors={colors} fontSize={12} gap={0.6} callout={callout} color="#252424"/>
                </div>
              </section>
              <section className="page-articles">
                <h3 className="section-title">Sources</h3>
                <ul className="articles">
                  {_.first(claim.articlesByStance(this.state.filter), 10).map(function(article) {
                    return (
                      <li key={article.id}>
                        <article className="article">
                          <header className="article-header">
                            <div className={'stance stance-' + article.stance}>
                              <span className="stance-value">{article.stance}</span>
                            </div>
                            {article.revised ?
                              <div className={'stance stance-revised stance-' + article.revised}>
                                <span className="stance-value">{'Revised to ' + article.revised}</span>
                              </div>
                            : ''}
                          </header>
                          <div className="article-content">
                            <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{article.source}</Link> - <time dateTime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                            <p className="article-description">{article.headline}</p>
                          </div>
                          <footer className="article-footer">
                            <div className="shares">
                              <span className="shares-value">{this.formatNumber(article.shares)}</span>
                              <span className="shares-label">shares</span>
                            </div>
                          </footer>
                        </article>
                      </li>
                    )
                  }, this)}
                </ul>
              </section>
            </div>
          </div>
        : null }
      </div>
    );
  }
});
