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
    return { filter: null };
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

  setFilter: function(filter) {
    this.setState({ filter: filter });
  },

  render: function() {
    var claim = this.state.claim;
    var shares = claim.sharesByStance();
    var colors = [
      '#7ecc76',
      '#dd5b53',
      '#f9be58'
    ];

    if (this.state.populated) {
      var slices = claim.aggregateSlices();
      var data = slices.reduce(function(series, slice) {
        series[0].push(slice.for||0);
        series[1].push(slice.against||0);
        series[2].push(slice.observing||0);
        return series;
      }.bind(this), [[],[],[]]);

      // find x-axis labels
      var skips = 1;
      if (slices.length > 10) { skips = 3; }
      if (slices.length > 25) { skips = 6; }
      if (slices.length > 50) { skips = 12; }
      var labels = slices.map(function(slice, i) {
        return i%skips ? '' : moment(slice.time).format('M/D');
      });

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

      // place callout for confirmation
      var callout;
      if (claim.get('truthinessDate')) {
        callout = {
          position: _.find(_.range(slices.length), function(s) { return slices[s].time > new Date(claim.get('truthinessDate')); }),
          text: 'Confirmed ' + claim.get('truthiness')
        };
      }
      window.callout = callout;

      var mostShared = _.first(claim.articlesByStance());
    }

    // compose in order of filter
    if (this.state.filter) {
      filterIndex = ['for', 'against', 'observing'].indexOf(this.state.filter);
      colors = [colors[filterIndex], '#eaeaea', '#eaeaea'];
      data.unshift(data.splice(filterIndex,1)[0]);
    }

    var mostShared = _.first(claim.articlesByStance()),
      startedTracking = claim.startedTracking();

    return (
      <div className="container">
        <div className="page page-claim">

          <div className="section">
            <header className="page-header">
              <h1 className="page-title">{claim.get('headline')}</h1>
              <p>{claim.get('description')}</p>
              <ul className="list-unstyled">
                {claim.get('origin') ? <li><strong>Originated: </strong>{claim.get('originUrl') ? <a href={claim.get('originUrl')} target="_blank">View article</a> : claim.get('origin')}</li> : null}
                <li><strong>Started Tracking:</strong> {moment(startedTracking).format('MMM. D, YYYY H:mm Z') + ' (' + moment(startedTracking).fromNow() + ')'}</li>
              </ul>
            </header>
            <div className="page-meta">
              <div className={'status status-' + claim.get('truthiness')}>
                <span className="status-label">Claim state</span>
                <span className="status-value">{claim.get('truthiness')}</span>
              </div>
              <div className={'status status-' + (mostShared ? mostShared.stance : '')}>
                <span className="status-label">Most shared</span>
                <span className="status-value">{mostShared ? mostShared.stance : ''}</span>
              </div>
            </div>
          </div>

          <section className="filters filters-section">
            <button onClick={this.setFilter.bind(this, null)} className="filter filter-all">
              <div className="filter-content">
                <h4 className="filter-title">All</h4>
                <p className="filter-sources">{claim.articlesByStance().length} sources</p>
                <div className="shares">
                  <span className="shares-value">{_.reduce(shares, function(sum, num) { return sum + num; }, 0)}</span>
                  <span className="shares-label">Shares</span>
                </div>
              </div>
            </button>
            <div className="filter-categories">
              <button onClick={this.setFilter.bind(this, 'for')} className="filter filter-category filter-category-for">
                <div className="filter-content">
                  <p className="filter-title">For</p>
                  <p className="filter-sources">{claim.articlesByStance('for').length} sources</p>
                  <div className="shares">
                    <span className="shares-value">{shares.for ? shares.for : 0}</span>
                    <span className="shares-label">Shares</span>
                  </div>
                </div>
                <div className="filter-article">
                  <p>Top Source</p>
                  {_.first(claim.articlesByStance('for'), 1).map(function(article) {
                    return (
                      <article className={'article' + (article.revised ? ' is-revised' : '')} key={article.id}>
                        <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{article.source}</Link> - <time datetime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                        <p className="article-description">{article.headline}</p>
                        <p>{article.shares} shares</p>
                      </article>
                    )
                  })}
                </div>
              </button>
              <button onClick={this.setFilter.bind(this, 'against')} className="filter filter-category filter-category-against">
                <div className="filter-content">
                  <p className="filter-title">Against</p>
                  <p className="filter-sources">{claim.articlesByStance('against').length} sources</p>
                  <div className="shares">
                    <span className="shares-value">{shares.against ? shares.against : 0}</span>
                    <span className="shares-label">Shares</span>
                  </div>
                </div>
                <div className="filter-article">
                  <p>Top Source</p>
                  {_.first(claim.articlesByStance('against'), 1).map(function(article) {
                    return (
                      <article className={'article' + (article.revised ? ' is-revised' : '')} key={article.id}>
                        <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{article.source}</Link> - <time datetime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                        <p className="article-description">{article.headline}</p>
                        <p>{article.shares} shares</p>
                      </article>
                    )
                  })}
                </div>
              </button>
              <button onClick={this.setFilter.bind(this, 'observing')} className="filter filter-category filter-category-observing">
                <div className="filter-content">
                  <p className="filter-title">Observing</p>
                  <p className="filter-sources">{claim.articlesByStance('observing').length} sources</p>
                  <div className="shares">
                    <span className="shares-value">{shares.observing ? shares.observing : 0}</span>
                    <span className="shares-label">Shares</span>
                  </div>
                </div>
                <div className="filter-article">
                  <p>Top Source</p>
                  {_.first(claim.articlesByStance('observing'), 1).map(function(article) {
                    return (
                      <article className={'article' + (article.revised ? ' is-revised' : '')} key={article.id}>
                        <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{article.source}</Link> - <time datetime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                        <p className="article-description">{article.headline}</p>
                        <p>{article.shares} shares</p>
                      </article>
                    )
                  })}
                </div>
              </button>
            </div>
          </section>

          <section className="section">
            <h3 className="section-title">Shares over time</h3>
            {this.state.populated ?
              <Barchart width={800} height={200} ref="chart" marginLeft={80} ylabels={ylabels} labels={labels} series={data} colors={colors} fontSize={12} gap={0.1} callout={callout}/>
              :
              <div>Loading</div>
            }
          </section>

          <section className="page-articles">
            <h3 className="articles-title">Sources</h3>
            <ul className="articles">
              {_.first(claim.articlesByStance(this.state.filter), 10).map(function(article) {
                //console.log(article);
                return (
                  <li key={article.id}>
                    <article className={'article' + (article.revised ? ' is-revised' : '')}>
                      <header className="article-header">
                        <div className={'stance stance-' + article.stance}>
                          <span className="stance-value">{article.stance}</span>
                        </div>
                        {article.revised ? 'Revised' : null}
                      </header>
                      <div className="article-content">
                        <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{article.source}</Link> - <time datetime={article.createdAt}>{moment(article.createdAt).format('MMMM Do YYYY')}</time></h4>
                        <p className="article-description">{article.headline}</p>
                      </div>
                      <footer className="article-footer">
                        <div className="shares">
                          <span className="shares-value">{article.shares}</span>
                          <span className="shares-label">Shares</span>
                        </div>
                      </footer>
                    </article>
                  </li>
                )
              })}
            </ul>
          </section>
        </div>
      </div>
    );
  }
});
