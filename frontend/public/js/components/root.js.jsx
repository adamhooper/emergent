/** @jsx React.DOM */

var React = require('react');
var Router = require('react-router');
var Link = Router.Link;

var nUpdatesToIgnore = 2;

module.exports = React.createClass({
  mixins: [ Router.ActiveState ],

  getInitialState: function() {
    return {
      searchToggle: false,
      navToggle: false,
      search: null
    }
  },

  setSearch: function(e) {
    this.setState({
      search: e.target.value
    });
  },

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

  openSearch: function() {
    this.setState({searchToggle: true});
    this.refs.searchTextInput.getDOMNode().focus();
  },

  closeSearch: function() {
    this.setState({searchToggle: false});
  },

  toggleNav: function() {
    this.setState({navToggle: !this.state.navToggle});
  },

  render: function() {
    return (
      <div>
        <header className={this.state.navToggle ? 'site-header nav-toggle-active in' : 'site-header out'}>
          <div className="site-header-primary container">
            <p className="site-logo"><Link to="claims">Emergent</Link></p>
            <nav className="site-menu">
              <button className="site-menu-toggle" href="#navigation" onClick={this.toggleNav}><span>Open Navigation</span></button>
              <ul className="navigation navigation-site">
                <li><a href="http://emergentinfo.tumblr.com/" className="navigation-link">Blog</a></li>
                <li><Link to="about" className="navigation-link">About Emergent</Link></li>
              </ul>
            </nav>
          </div>
        </header>
        <header className="site-header-categories">
          <div className="container">
            <nav className="site-menu-categories">
              <ul className="navigation navigation-categories">
                <li><Link to="claims" className="navigation-link">Home</Link></li>
                <li><Link to="category" params={{ category: 'Culture' }} className="navigation-link">Culture</Link></li>
                <li><Link to="category" params={{ category: 'Business%2FTech' }} className="navigation-link">Business</Link></li>
                <li><Link to="category" params={{ category: 'World' }} className="navigation-link">World News</Link></li>
                <li><Link to="category" params={{ category: 'Viral' }} className="navigation-link">Viral News</Link></li>
              </ul>
            </nav>
          </div>
        </header>
        <header className={this.state.searchToggle ? 'site-header-secondary search-toggle-active in' : 'site-header-secondary out'}>
          <div className="container">
            <div className="page-title-holder">
              <h2 className="page-title">Home</h2>
            </div>
            <div className="search-holder">
              <nav className="site-menu-trending">
                <span className="label">Trending:</span>
                <ul className="navigation navigation-trending">
                  {_.map(this.props.claims.trendingTags(), function(tag, i) {
                    return <li key={i}><Link to="tag" params={{ tag: tag }} className="navigation-link">{tag}</Link></li>
                  })}
                </ul>
              </nav>
              <div className="articles-search">
                <button className="search-toggle" onClick={this.openSearch}><span className="icon icon-search">Search</span></button>
                <div className="articles-search-holder">
                  <div className="inner">
                    <button className="search-close" onClick={this.closeSearch}><span className="icon icon-close">Close</span></button>
                    <input type="search" id="claims-filter" ref="searchTextInput" value={this.state.search} placeholder="Search" onChange={this.setSearch}/>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </header>
        <this.props.activeRouteHandler search={this.state.searchToggle && this.state.search} claims={this.props.claims}/>
      </div>
    );
  }
});
