/** @jsx React.DOM */

var React = require('react');
var Router = require('react-router');
var Link = Router.Link;

module.exports = React.createClass({

  getInitialState: function() {
    return {
      searchToggle: this.props.searchToggle
    }
  },

  openSearch: function() {
    this.setState({searchToggle: true});
    this.refs.searchTextInput.getDOMNode().focus();
  },

  closeSearch: function() {
    this.setState({searchToggle: false});
  },

  render: function() {
    return (
      <div>
        <header className="site-header-categories">
          <div className="container">
            <nav className="site-menu-categories">
              <ul className="navigation navigation-categories">
                <li><Link to="claims" className="navigation-link">Home</Link></li>
                <li><Link to="category" params={{ category: 'Culture' }} className="navigation-link">Culture</Link></li>
                <li><Link to="category" params={{ category: 'Business%2FTech' }} className="navigation-link">Business</Link></li>
                <li><Link to="category" params={{ category: 'World' }} className="navigation-link">World News</Link></li>
                <li><Link to="category" params={{ category: 'US' }} className="navigation-link">U.S. News</Link></li>
                <li><Link to="category" params={{ category: 'Viral' }} className="navigation-link">Viral News</Link></li>
              </ul>
            </nav>
          </div>
        </header>
        <header className={this.state.searchToggle ? 'site-header-secondary search-toggle-active in' : 'site-header-secondary out'}>
          <div className="container">
            <div className="page-title-holder">
              <h2 className="page-title">{this.props.category || 'Home'}</h2>
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
                    <input type="search" id="claims-filter" ref="searchTextInput" value={this.props.search} placeholder="Search" onChange={this.props.onChange}/>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </header>
      </div>
    );
  }
});