/** @jsx React.DOM */

var React = require('react');
var _ = require('underscore');

module.exports = React.createClass({

  propTypes: {
    width: React.PropTypes.number,
    height: React.PropTypes.number,
    marginTop: React.PropTypes.number,
    marginBottom: React.PropTypes.number,
    marginLeft: React.PropTypes.number,
    marginRight: React.PropTypes.number,
    gap: React.PropTypes.number,
    fontSize: React.PropTypes.number,
    minLength: React.PropTypes.number,
    series: React.PropTypes.arrayOf(React.PropTypes.arrayOf(React.PropTypes.number)),
    colors: React.PropTypes.arrayOf(React.PropTypes.string),
    labels: React.PropTypes.arrayOf(React.PropTypes.string),
    ylabels: React.PropTypes.arrayOf(React.PropTypes.number)
  },

  getDefaultProps: function() {
    return {
      width: 100,
      height: 100,
      marginTop: 20,
      marginBottom: 50,
      marginLeft: 10,
      marginRight: 20,
      fontSize: 20,
      minLength: 10, // minimum number of bars to leave space for
      gap: 0, // gap width as a percentage of bar width
      series: [[]], // array of arrays of data
      colors: ['black'] // array of colors for each series
    };
  },

  barWidth: function() {
    return this.props.width / (this.seriesSize() + this.seriesSize() * this.props.gap - this.props.gap);
  },

  seriesSize: function() {
    return _.max([this.props.minLength, _.max(_.pluck(this.props.series, 'length'))]);
  },

  heights: function() {
    return this.props.series.reduce(function(heights, data) {
      data.forEach(function(amount, i) {
        heights[i] = (heights[i]||0) + amount;
      });
      return heights;
    }, []);
  },

  highest: function() {
    return _.max(this.heights());
  },

  render: function() {
    var heights = [];
    var width = this.barWidth();
    var gap = width * this.props.gap;
    var heightFactor = this.props.height ? _.min([1, this.props.height / this.highest()]) : 0;
    var colors = this.props.colors;
    var height = this.props.height;

    var bars = _.flatten(this.props.series.map(function(data, s) {
      return data.map(function(amount, i) {
        heights[i] = (heights[i]||0) + amount * heightFactor;
        return {
          y: height - (heights[i]||0) + this.props.marginTop,
          x: (width + gap) * i + this.props.marginLeft,
          width: width,
          height: amount * heightFactor,
          fill: colors[s],
          key: "bar_" + s + "_" + i
        };
        return attrs;
      }.bind(this));
    }.bind(this)));

    var labels = this.props.labels.map(function(label, i) {
      return {
        y: height + this.props.fontSize + this.props.marginTop,
        x: (width + gap) * i + this.props.marginLeft,
        fontSize: this.props.fontSize,
        fill: 'black',
        __html: label,
        key: "label_" + i
      };
    }.bind(this));

    var ylabels = this.props.ylabels.map(function(label, i) {
      return {
        y: height - (label * heightFactor) + this.props.marginTop,
        x: this.props.marginLeft - 10,
        fontSize: this.props.fontSize,
        fill: 'black',
        textAnchor: 'end',
        __html: new String(label).replace(/(\d)(?=(\d{3})+$)/g, '$1,'),
        key: "ylabel_" + i
      };
    }.bind(this));

    var callout, calloutText;
    if (this.props.callout) {
      var x = (width + gap) * this.props.callout.position + this.props.marginLeft - (gap / 2);
      var callout = <line x1={x} x2={x} y1="0" y2={height + this.props.marginTop + this.props.marginBottom} stroke="black" strokeDasharray="5,5" />
      var calloutText = <text x={x + 5} y={this.props.fontSize + 25} fontSize={this.props.fontSize} fill="black">{this.props.callout.text}</text>
    }

    return (
      <svg width={this.props.width + this.props.marginLeft + this.props.marginRight} height={this.props.height + this.props.marginTop + this.props.marginBottom}>
        <g>
          {bars.map(function(bar) { return React.DOM.rect(bar); })}
        </g>
        <g>
          {labels.map(function(label) { return React.DOM.text(label, label.__html); })}
          {ylabels.map(function(label) { return React.DOM.text(label, label.__html); })}
          {callout}
          {calloutText}
        </g>
      </svg>
    );
  }
});
