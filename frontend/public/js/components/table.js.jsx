/** @jsx React.DOM */

var React = require('react');
var BackboneCollection = require('../mixins/backbone_collection.js');
var _ = require('underscore');

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
    claim.populate(1).done(function() {
      this.processData();
    }.bind(this));
    window.claim = claim;
  },

  processData: function() {
    var slices = claim.aggregateSlices().slice(0, 18);
    var data = slices.reduce(function(series, slice) {
      series[0].push(slice.for||0);
      series[1].push(slice.against||0);
      series[2].push(slice.observing||0);
      return series;
    }.bind(this), [[],[],[]]);
    this.setState({
      slices: slices,
      data: data,
      populated: true
    });
  },

  render: function() {
    return (
      <table>
      <tr>
        <th>date</th><th>nArticles</th><th>bodyFor</th><th>bodyAgainst</th><th>bodyObserving</th><th>bodyNull</th><th>headlineFor</th><th>headlineAgainst</th><th>headlineObserving</th><th>headlineIgnoring</th><th>headlineNull</th>
      </tr>
      {_.map(claim.aggregateSlices2(), function(slice) {
        return (
          <tr>
            <td>{slice.date}</td>
            <td>{slice.nArticles}</td>
            <td>{slice.bodyfor}</td>
            <td>{slice.bodyagainst}</td>
            <td>{slice.bodyobserving}</td>
            <td>{slice.bodynull}</td>
            <td>{slice.headlinefor}</td>
            <td>{slice.headlineagainst}</td>
            <td>{slice.headlineobserving}</td>
            <td>{slice.headlineignoring}</td>
            <td>{slice.headlinenull}</td>
          </tr>
        );
      })}
      </table>
    );
  }
});
