/** @jsx React.DOM */

var React = require('react');
var Router = require('react-router');
var Link = Router.Link;

var lastPathname = window.location.pathname;

module.exports = React.createClass({
  mixins: [ Router.ActiveState ],

  getInitialState: function() {
    return {
      navToggle: false
    }
  },

  updateActiveState: function() {
    if (lastPathname != window.location.pathname) {
      console.log('New pathname', lastPathname, window.location.pathname);
      lastPathname = window.location.pathname;
      window.ga('send', 'pageview')
    }
  },

  toggleNav: function() {
    this.setState({navToggle: !this.state.navToggle});
  },

  render: function() {
    return (
      <div>
        <header className={this.state.navToggle ? 'site-header nav-toggle-active in' : 'site-header out'}>
          <div className="site-header-primary container">
            <Link to="claims" className="site-logo"><span className="emergent">Emergent</span><span className="tagline">A real-time rumor tracker.</span></Link>
            <nav className="site-menu">
              <button className="site-menu-toggle" href="#navigation" onClick={this.toggleNav}><span>Open Navigation</span></button>
              <ul className="navigation navigation-site">
                <li><a href="http://emergentinfo.tumblr.com/" className="navigation-link">Blog</a></li>
                <li><Link to="about" className="navigation-link">About Emergent</Link></li>
              </ul>
            </nav>
          </div>
        </header>
        <this.props.activeRouteHandler claims={this.props.claims}/>
        <footer className="site-footer">
          <div className="container">
            <div className="copyright">&copy; Emergent 2015</div>
            <nav className="footer-menu">
              <ul className="navigation navigation-footer">
                <li><a href="http://emergentinfo.tumblr.com/" className="navigation-link">Blog</a></li>
                <li><Link to="about" className="navigation-link">About Emergent</Link></li>
              </ul>
            </nav>
          </div>
        </footer>
      </div>
    );
  }
});
