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
      <div>
        <h1>{claim.domain(article)}</h1>
        <p><a href={article.url} target="_blank">{article.headline}</a></p>
        <p>{moment(article.createdAt).format('MMMM Do YYYY')}</p>
        <ul>
          {slices.map(function(slice) {
            var headlineChanged = last && last.headlineStance != slice.headlineStance
            var bodyChanged = last && last.stance != slice.stance;
            var initial = !last;
            last = article;
            return (
              <li>
                <p>stamp: {moment(slice.end).format('MMMM Do YYYY h:mma')}</p>
                { initial ?
                  <p>Initially published. Headline {slice.headlineStance} Body {slice.stance}</p>
                    :
                  <p>
                    { headlineChanged ? <span> Headline changed: {slice.headlineStance} </span> : null }
                    { bodyChanged ? <span> Body changed: {slice.stance} </span> : null }
                  </p>
                }
                <p>shares: {_.values(slice.shares).reduce(function(sum, count) { return sum + count; }, 0)}</p>
              </li>
            );
          })}
        </ul>

        <ul>
          {_.map(shares, function(count, provider) {
            return <li>{provider}: {count}</li>
          })}
        </ul>
      </div>
    );
  }
});