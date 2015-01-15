/** @jsx React.DOM */

var React = require('react');
var BackboneCollection = require('../mixins/backbone_collection.js');
var Barchart = require('./bar_chart.js.jsx');
var Router = require('react-router');
var Link = Router.Link;
var _ = require('underscore');
var moment = require('moment');
var Autolinker = require('autolinker');

moment.locale('en', {
  calendar : {
    lastDay : '[Yesterday]',
    sameDay : '[Today]',
    nextDay : '[Tomorrow]',
    lastWeek : 'MMM D',
    sameElse : 'MMM D'
  }
});

module.exports = React.createClass({

  mixins: [BackboneCollection],

  getInitialState: function() {
    return {
      filter: null,
      filterHeights: { 'for': 1, against: 1, observing: 1 }
    };
  },

  componentWillMount: function() {
    this.update(this.props.params.slug);
  },

  componentWillReceiveProps: function(props) {
    this.update(props.params.slug);
  },

  update: function(slug) {
    if (slug != this.state.slug) {
      var claim = this.props.claims.findWhere({ slug: slug });
      this.subscribeTo(claim);
      this.setState({
        slug: slug,
        claim: claim,
        populated: false
      });
      claim.populate().done(function() {
        this.setState({ populated: true });
      }.bind(this));
    }
  },

  componentDidMount: function() {
    this.setState({ barChartWidth: 926 });
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

  heading: function() {
    return this.state.claim && this.state.claim.get('categories') && this.state.claim.get('categories').join(' - ');
  },

  formatNumber: function(str) {
    return new String(str).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  },

  truncateString: function(str) {
    return str.length > 70 ? str.substring(0, str.lastIndexOf(' ', 70)) + '...' : str;
  },

  render: function() {
    var linker = new Autolinker();
    var claim = this.state.claim;
    var shares = claim.sharesByStance();
    var colors = [
      '#00bf71',
      '#e70909',
      '#656565'
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

    var lastDate;

    var resolvedClaim = claim.get('truthinessUrl');

    var originClaim = claim.get('originUrl');
    var nextClaim = claim.nextByCategory();

    return (

      <div>
        <app.components.Header claims={this.props.claims} search="" category={this.heading()}/>
        <div className="page page-claim">
          <div className="page-header">
            <div className="container">
              <div className="section section-with-sidebar">
                <header className="section-header with-stance">
                  <div className={'stance stance-' + claim.get('truthiness')}>
                    <span className="stance-value">{claim.truthinessText()}</span>
                  </div>
                  <h1 className="page-title">{claim.get('headline')}</h1>
                  <p className="article-content" dangerouslySetInnerHTML={{__html: linker.link(claim.get('description'))}}/>
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


                  {claim.get('truthiness') != 'unknown' ? <p className="tracking"><span className="tracking-header">Resolved{claim.get('truthinessUrl') ? <span className="article-source">:<span className="spacer-10"></span><a href={claim.get('truthinessUrl')}>{claim.prettyUrl(claim.get('truthinessUrl'))}</a></span> : null }
                  <span className="spacer-10"></span>Added {moment(truthinessDate).format('MMM D')}</span><br /><span className="tracking-body">{claim.get('truthinessDescription')}</span></p> : null}

                  {claim.get('origin') ? <p className="tracking"><span className="tracking-header">Originating Source{claim.get('originUrl') ? <span className="article-source">:<span className="spacer-10"></span><a href={claim.get('originUrl')}>{claim.prettyUrl()}</a></span> : null }
                  <span className="spacer-10"></span>Added {moment(originDate).format('MMM D')}</span><br /><span className="tracking-body" dangerouslySetInnerHTML={{__html: linker.link(claim.get('origin'))}}/></p> : null}
                </header>
              </div>
              <nav className="page-navigation">
                <ul className="navigation navigation-page">
                  <li className="navigation-social">
                    <span className="navigation-label">Share this claim:</span>
                    <a href={'https://twitter.com/intent/tweet?text='+claim.get('headline')+'&via=emergentdotinfo&url='+encodeURIComponent(document.URL)} target="_blank" className="navigation-link"><span className="icon icon-twitter-round"></span>Share on Twitter</a>
                    <a href={'https://www.facebook.com/sharer/sharer.php?u='+encodeURIComponent(document.URL)} target="_blank" className="navigation-link"><span className="icon icon-facebook-round"></span>Share on Facebook</a>
                  </li>
                  {/*<li>
                    <app.components.Modal title="Dispute this claim" trigger={<a href="#" className="navigation-link"><span className="icon icon-dispute"></span>Dispute this claim</a>}>
                      Lorem Ipsum
                    </app.components.Modal>
                  </li>*/}
                </ul>
              </nav>
            </div>
          </div>

          { this.state.populated ?
          <div className="page-meta">
            <div className="container">

              <div className="meta">
                <h3 className="meta-title">Sources</h3>
                <div className="shares">
                  <span className="shares-label">Sources Tracked:</span> <span className="shares-value">{claim.articlesByStance().length}</span>
                </div>
                <div className="shares">
                  <span className="shares-label">Total Shares:</span> <span className="shares-value">{this.formatNumber(claim.get('nShares'))}</span>
                </div>
              </div>

              <section className="cards cards-section">
                <div className={'card-categories card-categories-' + _.filter(claim.sharesByStance(), function(c) { return c; }).length}>
                  { claim.articlesByStance('for').length > 0 ?
                    <div onClick={this.setFilter.bind(this, 'for')} className={'card card-category card-category-for' + (this.state.filter === 'for' ? ' is-selected' : '')}>
                      <div className="card-header">
                        <p className="card-title">For{claim.get('truthiness') === 'true' ? <span className="icon icon-confirmed-stance">Confirmed</span> : null}</p>
                      </div>
                      <div className="card-content">
                        <div className="sources"><span className="sources-count">{claim.articlesByStance('for').length}</span><span className="indicator-holder" dangerouslySetInnerHTML={{__html: Array(claim.articlesByStance('for').length + 1).join('<span class="indicator indicator-true"></span>')}}/></div>
                        <div className="shares">
                          <span className="shares-label">Shares</span>
                          <span className="shares-value">{shares.for ? this.formatNumber(shares.for) : 0}</span>
                        </div>
                      </div>
                    </div>
                    : null
                  }
                  { claim.articlesByStance('against').length > 0 ?
                    <div onClick={this.setFilter.bind(this, 'against')} className={'card card-category card-category-against' + (this.state.filter === 'against' ? ' is-selected' : '')}>
                      <div className="card-header">
                        <p className="card-title">Against{claim.get('truthiness') === 'false' ? <span className="icon-confirmed-stance">Confirmed</span> : null}</p>
                      </div>
                      <div className="card-content">
                        <div className="sources"><span className="sources-count">{claim.articlesByStance('against').length}</span><span className="indicator-holder" dangerouslySetInnerHTML={{__html: Array(claim.articlesByStance('against').length + 1).join('<span class="indicator indicator-false"></span>')}}/></div>
                        <div className="shares">
                          <span className="shares-label">Shares</span>
                          <span className="shares-value">{shares.against ? this.formatNumber(shares.against) : 0}</span>
                        </div>
                      </div>
                    </div>
                    : null
                  }
                  { claim.articlesByStance('observing').length > 0 ?
                    <div onClick={this.setFilter.bind(this, 'observing')} className={'card card-category card-category-observing' + (this.state.filter === 'observing' ? ' is-selected' : '')}>
                      <div className="card-header">
                        <p className="card-title">Observing</p>
                      </div>
                      <div className="card-content">
                        <div className="sources"><span className="sources-count">{claim.articlesByStance('observing').length}</span><span className="indicator-holder" dangerouslySetInnerHTML={{__html: Array(claim.articlesByStance('observing').length + 1).join('<span class="indicator indicator-unknown"></span>')}}/></div>
                        <div className="shares">
                          <span className="shares-label">Shares</span>
                          <span className="shares-value">{shares.observing ? this.formatNumber(shares.observing) : 0}</span>
                        </div>
                      </div>
                    </div>
                    : null
                  }
                </div>
              </section>

            </div>
          </div>
          : null }

          <nav className="sources-filtering">
            <div className="container">
              <ul className="navigation navigation-filtering">
                <li><button onClick={this.setFilter.bind(this, null)} className={'navigation-link' + (!this.state.filter ? ' active' : '')}>All</button></li>
                { claim.articlesByStance('for').length > 0 ? <li><button onClick={this.setFilter.bind(this, 'for')} className={'navigation-link' + (this.state.filter === 'for' ? ' active' : '')}><span className="indicator indicator-true"></span> For</button></li> : null }
                { claim.articlesByStance('against').length > 0 ? <li><button onClick={this.setFilter.bind(this, 'against')} className={'navigation-link' + (this.state.filter === 'against' ? ' active' : '')}><span className="indicator indicator-false"></span> Against</button></li> : null }
                { claim.articlesByStance('observing').length > 0 ? <li><button onClick={this.setFilter.bind(this, 'observing')} className={'navigation-link' + (this.state.filter === 'observing' ? ' active' : '')}><span className="indicator indicator-unknown"></span> Observing</button></li> : null }
              </ul>
            </div>
          </nav>


          <div className="container page-claim-body">

            {this.state.populated ?
              <div className="page-content">
                <div className="container">
                  <div className="section section-with-sidebar">
                    {/*<section className="shares-over-time">
                      <div className="section">
                        <h3 className="section-title">Shares Over Time</h3>
                        <div className="section-content">
                          <Barchart width={this.state.barChartWidth - 120} height={200} ref="chart" marginBottom={20} marginTop={callout ? 75: 10} marginLeft={100} marginRight={20} ylabels={ylabels} labels={labels} series={data} colors={colors} fontSize={12} gap={0.6} callout={callout} color="#252424"/>
                        </div>
                      </div>
                    </section>*/}
                    <section className="page-timeline">
                      <ul className="articles">
                        {claim.articlesByStance(this.state.filter).map(function(article) {

                          var date = moment(article.createdAt).calendar();

                          var jsx = (
                            <li key={article.id}>
                              {date !== lastDate ?
                              <span className="article-header-date">{moment(article.createdAt).calendar()}</span>
                              : null }
                              <article className="article with-stance">
                                {resolvedClaim === article.url ?
                                <div>
                                  <span className="icon icon-resolved">Resolved</span>
                                  <div className={'stance stance-changing'}>
                                    <span className="stance-value">Resolved</span>
                                  </div>
                                </div>
                                : null }
                                {originClaim === article.url ?
                                  <div>
                                    <span className="icon icon-added">Originated</span>
                                    <div className={'stance stance-changing'}>
                                      <span className="stance-value">Originated</span>
                                    </div>
                                  </div>
                                  : null }
                                <div className="article-content">
                                  <h4 className="article-list-title"><span className={'indicator indicator-' + article.stance}></span> <a href={article.url}>{claim.prettyUrl(article.url)}</a> - <time className="no-wrap" dateTime={article.createdAt}>{moment(article.createdAt).format('MMM D')}</time>
                                    <span className="no-wrap"><span className="shares-label">Shares:</span> <span className="shares-value">{this.formatNumber(article.shares)}</span></span>
                                    </h4>
                                  <p className="article-description">{article.headline}</p>
                                </div>
                              </article>
                            </li>
                          );

                          lastDate = date;

                          return jsx;
                        }, this)}
                      </ul>
                    </section>
                  </div>
                  <nav className="page-navigation">
                    {/*<ul className="navigation navigation-page">
                      <li>
                        <app.components.Modal title="Submit a source" trigger={<a href="#" className="navigation-link"><span className="icon icon-submit-a-source"></span>Submit a source</a>}>
                          Lorem Ipsum
                        </app.components.Modal>
                      </li>
                    </ul>*/}
                  </nav>
                </div>
              </div>
            : null }
          </div>

          <nav className="navigation-footer-social">
            <div className="container">
              <ul className="navigation">
                <li>
                  <span className="navigation-label">Share this claim:</span>
                </li>
                <li>
                  <a href={'https://twitter.com/intent/tweet?text='+claim.get('headline')+'&via=emergentdotinfo&url='+encodeURIComponent(document.URL)} target="_blank" className="navigation-link"><span className="icon icon-twitter-round"></span></a>
                </li>
                <li>
                  <a href={'https://www.facebook.com/sharer/sharer.php?u='+encodeURIComponent(document.URL)} target="_blank" className="navigation-link"><span className="icon icon-facebook-round"></span></a>
                </li>
              </ul>
            </div>
          </nav>

          {nextClaim ?
          <div className="claim-footer-next">
            <div className="container">
              <span className="next-label">Next in {claim.get('categories')[0]}:</span>
              <div className="next-link-holder">
                <div className={'stance stance-small stance-true'}>
                  <span className="stance-value">True</span>
                </div>
                <Link to="claim" params={{ slug: nextClaim.get('slug') }}>{nextClaim.get('headline')}</Link>
              </div>
            </div>
          </div>
          : null}

        </div>
      </div>
    );
  }
});
