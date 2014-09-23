/** @jsx React.DOM */

var React = require('react');

module.exports = React.createClass({
  render: function() {
    return (
      <div>
        <header className="site-header">
          <div className="container">
            <p className="site-logo">Emergent</p>
            <nav className="site-menu">
              <ul className="menu menu-site">
                <li><a href="#" className="menu-item active">Stories</a></li>
                <li><a href="#" className="menu-item">About</a></li>
                <li><a href="#" className="menu-item">Contact</a></li>
              </ul>
            </nav>
          </div>
        </header>
        <this.props.activeRouteHandler />
      </div>
    );
  }
});
