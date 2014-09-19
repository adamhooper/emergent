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
    var slices = claim.aggregateSlices();
    var data = slices.reduce(function(series, slice) {
      series[0].push(slice.for||0);
      series[1].push(slice.against||0);
      series[2].push(slice.observing||0);
      return series;
    }.bind(this), [[],[],[]]);
    var skips = 1;
    if (slices.length > 10) { skips = 3; }
    if (slices.length > 25) { skips = 6; }
    if (slices.length > 50) { skips = 12; }
    var labels = slices.map(function(slice, i) {
      return i%skips ? '' : moment(slice.time).format('M/D');
    });
    var callout;
    if (claim.get('truthinessDate')) {
      callout = {
        position: _.find(_.range(slices.length), function(s) { return slices[s].time > new Date(claim.get('truthinessDate')); }),
        text: 'Confirmed ' + claim.get('truthiness')
      };
    }
    window.callout = callout;

    // compose in order of filter
    if (this.state.filter) {
      filterIndex = ['for', 'against', 'observing'].indexOf(this.state.filter);
      colors = [colors[filterIndex], 'white', 'white'];
      data.unshift(data.splice(filterIndex,1)[0]);
    }

    var mostShared = _.first(claim.articlesByStance());

    return (
      <div className="container">
        <div className="page page-claim">

          <div className="section">
            <header className="page-header">
              <h1 className="page-title">{claim.get('headline')}</h1>
              <p>{claim.get('description')}</p>
              <ul>
                {claim.get('origin') ? <li><strong>Originated: </strong>{claim.get('originUrl') ? <a href={claim.get('originUrl')} target="_blank">{claim.get('origin')}</a> : claim.get('origin')}</li> : null}
                <li><strong>Started Tracking:</strong> {moment(claim.startedTracking()).format('MMMM Do YYYY')}</li>
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

          <section className="triggers triggers-section">
            <button onClick={this.setFilter.bind(this, null)} className="trigger trigger-all">
              All
              <p>{_.reduce(shares, function(sum, num) { return sum + num; }, 0) + ' shares'}</p>
              <p>{claim.articlesByStance().length} sources</p>
            </button>
            <button onClick={this.setFilter.bind(this, 'for')} className="trigger trigger-category">
              For
              <p>{shares.for ? shares.for : 0} shares</p>
              <p>{claim.articlesByStance('for').length} sources</p>
              {_.first(claim.articlesByStance('for'), 1).map(function(article) {
                return (
                  <article className={'article' + (article.revised ? ' is-revised' : '')} key={article.id}>
                    <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{claim.domain(article)}</Link> - <time datetime={article.createdAt}>{article.createdAt}</time></h4>
                    <p className="article-description">{article.headline}</p>
                    <p>{article.shares} shares</p>
                  </article>
                )
              })}
            </button>
            <button onClick={this.setFilter.bind(this, 'against')} className="trigger trigger-category">
              Against
              <p>{shares.against ? shares.against : 0} shares</p>
              <p>{claim.articlesByStance('against').length} sources</p>
              {_.first(claim.articlesByStance('against'), 1).map(function(article) {
                return (
                  <article className={'article' + (article.revised ? ' is-revised' : '')} key={article.id}>
                    <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{claim.domain(article)}</Link> - <time datetime={article.createdAt}>{article.createdAt}</time></h4>
                    <p className="article-description">{article.headline}</p>
                    <p>{article.shares} shares</p>
                  </article>
                )
              })}
            </button>
            <button onClick={this.setFilter.bind(this, 'observing')} className="trigger trigger-category">
              Observing
              <p>{shares.observing ? shares.observing : 0} shares</p>
              <p>{claim.articlesByStance('observing').length} sources</p>
              {_.first(claim.articlesByStance('observing'), 1).map(function(article) {
                return (
                  <article className={'article' + (article.revised ? ' is-revised' : '')} key={article.id}>
                    <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{claim.domain(article)}</Link> - <time datetime={article.createdAt}>{article.createdAt}</time></h4>
                    <p className="article-description">{article.headline}</p>
                    <p>{article.shares} shares</p>
                  </article>
                )
              })}
            </button>
          </section>

          <section className="section">
            <h3 className="section-title">Shares over time</h3>
            {this.state.populated ?
              <Barchart width={800} height={200} ref="chart" labels={labels} series={data} colors={colors} fontSize={12} gap={0.1} callout={callout}/>
              :
              <div>Loading</div>
            }
          </section>

          <section className="page-articles">
            <h3>Sources</h3>
            <ul className="articles">
              {_.first(claim.articlesByStance(this.state.filter), 10).map(function(article) {
                return (
                  <li key={article.id}>
                    <article className={'article' + (article.revised ? ' is-revised' : '')}>
                      <div className="stance">
                        <span className="stance-value">{article.stance}</span>
                      </div>
                      <h4 className="article-title"><Link to="article" params={{ slug: claim.get('slug'), articleId: article.id }}>{claim.domain(article)}</Link> - <time datetime={article.createdAt}>{article.createdAt}</time></h4>
                      <p className="article-description">{article.headline}</p>
                      {article.revised ? 'Revised' : ''}<br />
                      {moment(article.createdAt).format('MMMM Do YYYY')}
                      <div className="shares">
                        <span className="shares-value">{article.shares}</span>
                        <span className="shares-label">Shares</span>
                      </div>
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
