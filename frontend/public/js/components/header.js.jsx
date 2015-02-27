/** @jsx React.DOM */

var React = require('react');
var Router = require('react-router');
var Link = Router.Link;

var NavCategory = React.createClass({
  render: function() {
    var category = this.props.category;

    if (category.hidden) {
      return null;
    } else {
      return <li><Link to="category" params={{ category: encodeURIComponent(category.id) }} className="navigation-link">{ category.navTitle }</Link></li>;
    }
  }
});

var NavCategories = React.createClass({
  render: function() {
    var categories = this.props.categories;

    return (
      <header className="site-header-categories">
        <div className="container">
          <nav className="site-menu-categories">
            <ul className="navigation navigation-categories">
              <li><Link to="claims" className="navigation-link">Home</Link></li>
              { categories.map(function(category) {
                return <NavCategory key={"category-" + category.id} category={category}/>;
              })}
            </ul>
          </nav>
        </div>
      </header>
    );
  }
});

module.exports = React.createClass({

  mixins: [ Router.Navigation ],

  getInitialState: function() {
    return {
      search: this.props.search,
      searchToggle: !!this.props.search
    }
  },

  componentWillReceiveProps: function(props) {
    this.setState({
      search: props.search,
      searchToggle: !!props.search
    });
  },

  setSearch: function(e) {
    this.setState({ search: e.target.value });
  },

  openSearch: function() {
    this.setState({ searchToggle: true });
    this.refs.searchTextInput.getDOMNode().focus();
  },

  closeSearch: function() {
    this.setState({
      searchToggle: false,
      search: ''
    }, function() {
      this.handleSearch();
    });
  },

  handleSearch: function() {
    this.transitionTo('claims', {}, this.state.search ? { search: this.state.search } : {});
  },

  onKeyUp: function(e) {
    if (e.key === 'Enter') {
      this.handleSearch();
    }
  },

  render: function() {
    return (
      <div>
        <NavCategories categories={ this.props.categories }/>
        <header className={this.state.searchToggle ? 'site-header-secondary search-toggle-active in' : 'site-header-secondary out'}>
          <div className="container">
            <div className="page-title-holder">
              <h2 className="page-title">{this.props.category}</h2>
            </div>
            <div className="search-holder">
              <nav className="site-menu-trending">
                <span className="label">Trending:</span>
                <ul className="navigation navigation-trending">
                  {this.props.claims.trendingTags().map(function(tag, i) {
                    return <li key={"tag-" + i}><Link to="tag" params={{ tag: tag }} className="navigation-link">{tag}</Link></li>
                  })}
                </ul>
              </nav>
              <div className="articles-search">
                <button className="search-toggle" onClick={this.openSearch}><span className="icon icon-search">Search</span></button>
                <div className="articles-search-holder">
                  <div className="inner">
                    <button className="search-close" onClick={this.closeSearch}><span className="icon icon-close">Close</span></button>
                    <input type="search" id="claims-filter" ref="searchTextInput" value={this.state.search} placeholder="Search" onKeyUp={this.onKeyUp} onChange={this.setSearch}/>
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
