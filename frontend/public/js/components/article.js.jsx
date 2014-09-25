/** @jsx React.DOM */

var React = require('react');
var BackboneCollection = require('../mixins/backbone_collection.js');
var Link = require('react-router').Link;
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
      return (
        <div className="page page-article">
          <div className="page-content">
            <div className="container">
              <header className="section">
                <div className="section-header">
                  <h1 className="page-title">Loading</h1>
                </div>
              </header>
            </div>
          </div>
        </div>
      );
    }

    var last;

    return (
      <div className="page page-article">
        <div className="page-content">
          <div className="container">

            <div><Link to="claim" params={{ slug: claim.get('slug') }}>&lt;&lt; Back to {claim.get('headline')}</Link></div>
            <header className="section">
              <div className="section-header">
                <h1 className="page-title">{article.headline}</h1>
                <p>{article.source} - {moment(article.createdAt).format('MMM D YYYY')} ({slices.length + ' revision' + (slices.length > 1 ? 's' : '')})</p>
                <p><a href={article.url} target="_blank">View article</a></p>
                <p></p>
              </div>
              <div className="page-meta">
                <div className={'status status-' + _.last(slices).headlineStance}>
                  <span className="status-label">Headline</span>
                  <span className="status-value">{_.last(slices).headlineStance}</span>
                </div>
                <div className={'status status-' + _.last(slices).stance}>
                  <span className="status-label">Article Body</span>
                  <span className="status-value">{_.last(slices).stance}</span>
                </div>
              </div>
            </header>

            <h2 className="articles-title">Revisions</h2>
            <ul className="articles">
              {slices.map(function(slice) {
                var headlineChanged = last && last.headlineStance != slice.headlineStance
                var bodyChanged = last && last.stance != slice.stance;
                var initial = !last;
                var jsx = (
                  <li>
                    <article className="article article-revision">
                      <header className="article-header">
                        <h3 className="article-date">{moment(slice.end).format('MMM D YYYY')}</h3>
                        <p className="article-time">{moment(slice.end).format('h:mma')}</p>
                      </header>
                      <div className="article-content">
                          { initial ?
                              <ul className="changes">
                                <li>First Published Headline: <span style={{ textTransform: 'capitalize' }}>{slice.headlineStance}</span></li>
                                <li>Body: <span style={{ textTransform: 'capitalize' }}>{slice.stance}</span></li>
                              </ul>
                            :
                            <ul className="changes">
                              { headlineChanged ?
                                <li>
                                  Headline: Changed from <span style={{ textTransform: 'capitalize' }}>{last.headlineStance}</span> to <span style={{ textTransform: 'capitalize' }}>{slice.headlineStance}</span>
                                </li>
                                : null
                              }
                              { bodyChanged ?
                                <li>
                                  Article Body: Changed from <span style={{ textTransform: 'capitalize' }}>{last.stance}</span> to <span style={{ textTransform: 'capitalize' }}>{slice.stance}</span>
                                </li>
                                : null
                              }
                            </ul>
                          }
                      </div>
                      <footer className="article-footer">
                        <div className="shares">
                          <span className="shares-value">{_.values(slice.shares).reduce(function(sum, count) { return sum + count; }, 0)}</span>
                          <span className="shares-label">shares</span>
                        </div>
                      </footer>
                    </article>
                  </li>
                );
                last = slice;
                return jsx;
              })}
            </ul>
          </div>
        </div>
      </div>
    );
  }
});
