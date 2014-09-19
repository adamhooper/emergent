/** @jsx React.DOM */

var React = require('react');

module.exports = React.createClass({
  render: function() {
    return (
      <div>
        <header/>
        <this.props.activeRouteHandler />
      </div>
    );
  }
});
