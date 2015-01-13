/** @jsx React.DOM */

var React = require('react');
window.$ = window.jQuery = require('jquery');
var Modal = require('bootstrap/js/modal');

module.exports = React.createClass({
  componentDidMount: function() {
    // Initialize the modal, once we have the DOM node
    // TODO: Pass these in via props
    $(this.getDOMNode()).modal({background: true, keyboard: true, show: false});
  },
  componentWillUnmount: function() {
    $(this.getDOMNode()).off('hidden');
  },
  handleTrigger: function(e) {
    e.preventDefault();
    $(this.refs.payload.getDOMNode()).modal('show');
  },
  handleClose: function(e) {
    e.preventDefault();
    $(this.refs.payload.getDOMNode()).modal('hide');
  },
  // This was the key fix --- stop events from bubbling
  handleClick: function(e) {
    e.stopPropagation();
  },
  render: function() {
    return (
      <div>
        {this.props.trigger ?
        <div onClick={this.handleTrigger}>
          {this.props.trigger}
        </div>
        : null }
        <div onClick={this.handleClick} className="modal fade" role="dialog" aria-hidden="true" ref="payload">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <button type="button" onClick={this.handleClose} className="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 className="modal-title">
                  {this.props.title}
                </h4>
              </div>
              <div className="modal-body">
                {this.props.children}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
