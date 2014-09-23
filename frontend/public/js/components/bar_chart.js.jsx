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
    color: React.PropTypes.string,
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
      color: 'black', // main color for text/lines
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
    var heightFactor = this.props.height ? this.props.height / this.highest() : 0;
    var colors = this.props.colors;
    var height = this.props.height;

    var bars = _.flatten(this.props.series.map(function(data, s) {
      return data.map(function(amount, i) {
        heights[i] = (heights[i]||0) + amount * heightFactor;
        return {
          y: height - (heights[i]||0) + this.props.marginTop,
          x: (width + gap) * i + this.props.marginLeft,
          width: width,
          height: _.max([amount ? 1 : 0, amount * heightFactor]),
          fill: colors[s],
          key: "bar_" + s + "_" + i
        };
        return attrs;
      }.bind(this));
    }.bind(this)));

    var labels = this.props.labels.map(function(label, i) {
      return {
        y: height + this.props.fontSize*1.2 + this.props.marginTop,
        x: (width + gap) * i + (width/2) + this.props.marginLeft,
        fontSize: this.props.fontSize,
        textAnchor: 'middle',
        fill: this.props.color,
        __html: label,
        key: "label_" + i
      };
    }.bind(this));

    var ylabels = this.props.ylabels.map(function(label, i) {
      return {
        y: height - (label * heightFactor) + this.props.marginTop + this.props.fontSize/2,
        x: this.props.marginLeft - 18,
        fontSize: this.props.fontSize,
        fill: this.props.color,
        textAnchor: 'end',
        __html: new String(label).replace(/(\d)(?=(\d{3})+$)/g, '$1,'),
        key: "ylabel_" + i
      };
    }.bind(this));

    var callout, calloutText;
    if (this.props.callout) {
      var x = (width + gap) * this.props.callout.position + this.props.marginLeft - (gap / 2);
      var alignRight = x > this.props.width*.75; 
      var callout = <line x1={x} x2={x} y1="0" y2={height + this.props.marginTop} stroke={this.props.color} strokeWidth="2" strokeDasharray="2,7" />
      var calloutText = (
        <text y={this.props.fontSize + 25} fontSize={this.props.fontSize} fill={this.props.color}>
          {this.props.callout.text.map(function(tspan) {
            return <tspan x={x + (alignRight ? -5 : 5)} dy={1.2*this.props.fontSize} textAnchor={alignRight ? 'end' : 'start'}>{tspan}</tspan>
          }.bind(this))}
        </text>
      );
    }

    return (
      <svg width={this.props.width + this.props.marginLeft + this.props.marginRight} height={this.props.height + this.props.marginTop + this.props.marginBottom}>
        <g>
          {bars.map(function(bar) { return React.DOM.rect(bar); })}
          <line x1={this.props.marginLeft} x2={this.props.width + this.props.marginLeft} y1={this.props.marginTop + this.props.height} y2={this.props.marginTop + this.props.height} stroke="#999"/>
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
