/** @jsx React.DOM */

var React = require('react');
var Router = require('react-router');
var Link = Router.Link;

var nUpdatesToIgnore = 2;

module.exports = React.createClass({
  mixins: [ Router.ActiveState ],

  updateActiveState: function() {
    // react-router sends two updates on page load. We want zero, because
    // our first call to window.ga() happens when window.ga() actually
    // loads.
    if (nUpdatesToIgnore > 0) {
      nUpdatesToIgnore -= 1;
    } else {
      if (window.ga) {
        window.ga('send', 'pageview');
      }
    }
  },

  render: function() {
    return (
      <div>
        <header className="site-header">
          <div className="container">
            <p className="site-logo"><Link to="claims">Emergent</Link></p>
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
