/** @jsx React.DOM */

var React = require('react');
var BackboneCollection = require('../mixins/backbone_collection.js');
var _ = require('underscore');
var moment = require('moment');

module.exports = React.createClass({

  mixins: [BackboneCollection],

  componentWillMount: function() {
    var claim = this.props.claims.findWhere({ slug: this.props.params.slug });
    this.subscribeTo(claim);

    this.setState({
      claim: claim,
      populated: false
    });
    claim.populate().done(function() {
      this.setState({
        article: _.findWhere(claim.get('articles'), { id: this.props.params.articleId }),
        populated: true
      });
    }.bind(this));
    window.claim = claim;
  },

  render: function() {
    var article = this.state.article;
    var slices = this.state.claim.slicesByArticle(this.props.params.articleId);
    var shares = claim.sharesByArticle(this.props.params.articleId);

    if (!article) {
      return <div>Loading</div>
    }

    var last;

    return (
      <div className="container">
        <div className="page page-article">

          <header className="section">
            <div className="page-header">
              <h1 className="page-title">{article.headline}</h1>
              <p>{article.source}</p>
              <p><a href={article.url} target="_blank">View original article</a></p>
              <p>{moment(article.createdAt).format('MMMM Do YYYY')}</p>
            </div>
            <div className="page-meta">
              <div className={'status status-' + claim.get('truthiness')}>
                <span className="status-label">Claim state</span>
                <span className="status-value">{claim.get('truthiness')}</span>
              </div>
              <div className={'status status-'}>
                <span className="status-label">Most shared</span>
                <span className="status-value"></span>
              </div>
            </div>
          </header>

          <ul>
            {_.map(shares, function(count, stance) {
              return <li>{stance}: {count}</li>
            })}
          </ul>

          <h2 className="articles-title">Revisions</h2>
          <ul className="articles">
            {slices.map(function(slice) {
              var headlineChanged = last && last.headlineStance != slice.headlineStance
              var bodyChanged = last && last.stance != slice.stance;
              var initial = !last;
              last = article;
              return (
                <li>
                  <article className="article article-revision">
                    <header className="article-header">
                      <h3>{moment(slice.end).format('MMMM Do YYYY')}</h3>
                      <p>{moment(slice.end).format('h:mma')}</p>
                    </header>
                    <div className="article-content">
                      { initial ?
                        <p>Initially published. Headline {slice.headlineStance} Body {slice.stance}</p>
                          :
                        <p>
                          { headlineChanged ? <span> Headline changed: {slice.headlineStance} </span> : null }
                          { bodyChanged ? <span> Body changed: {slice.stance} </span> : null }
                        </p>
                      }
                    </div>
                    <footer className="article-footer">
                      <div className="shares">
                        <span className="shares-value">{_.values(slice.shares).reduce(function(sum, count) { return sum + count; }, 0)}</span>
                        <span className="shares-label">Shares</span>
                      </div>
                    </footer>
                  </article>
                </li>
              );
            })}
          </ul>
        </div>
      </div>
    );
  }
});
