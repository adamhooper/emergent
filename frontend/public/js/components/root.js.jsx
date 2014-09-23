/** @jsx React.DOM */

var React = require('react');
var Link = require('react-router').Link;

module.exports = React.createClass({
  render: function() {
    return (
      <div>
        <header className="site-header">
          <div className="container">
            <p className="site-logo">Emergent</p>
            <nav className="site-menu">
              <ul className="menu menu-site">
                <li><Link to="claims" className="menu-item">Stories</Link></li>
                <li><Link to="about" className="menu-item">About</Link></li>
                <li><a href="http://emergentinfo.tumblr.com/" className="menu-item">Blog</a></li>
              </ul>
            </nav>
          </div>
        </header>
        <this.props.activeRouteHandler />
      </div>
    );
  }
});
