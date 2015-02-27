/** @jsx React.DOM */

var $ = require('jquery');
var React = require('react');
var Router = require('react-router');
var Route = Router.Route;
var Routes = Router.Routes;
var DefaultRoute = Router.DefaultRoute;
var Root = require('./components/root.js.jsx');

var Categories = [
  { id: "Apple", title: "Apple", navTitle: "Apple", hidden: true },
  { id: "Culture", title: "Culture", navTitle: "Culture", hidden: false },
  { id: "Business/Tech", title: "Business/Tech", navTitle: "Business", hidden: false },
  { id: "World", title: "World", navTitle: "World", hidden: false },
  { id: "US", title: "US", navTitle: "US", hidden: false },
  { id: "Viral", title: "Viral", navTitle: "Viral", hidden: false }
];

var app = {
  init: function() {
    this.categories = Categories;
    this.claims = new this.collections.Claims();
    this.claims.url = 'http://api.emergent.info/claims'
    this.claims.fetch().done(function() {
      React.renderComponent(
        <Routes location="history">
          <Route path="/" handler={Root} claims={this.claims} categories={this.categories}>
            <DefaultRoute name="claims" handler={this.components.Claims}/>
            <Route name="about" path="about" handler={this.components.About}/>
            <Route name="claim" path=":slug" handler={this.components.Claim}/>
            <Route name="category" path="category/:category" handler={this.components.Claims}/>
            <Route name="tag" path="tag/:tag" handler={this.components.Claims}/>
          </Route>
        </Routes>
      , $('#react')[0]);
    }.bind(this));
  },

  components: {
    Claim: require('./components/claim.js.jsx'),
    Claims: require('./components/claims.js.jsx'),
    About: require('./components/about.js.jsx'),
    Header: require('./components/header.js.jsx'),
    Modal: require('./components/modal.js.jsx')
  },

  models: {
    Claim: require('./models/claim.js')
  },

  collections: {
    Claims: require('./collections/claims.js')
  }
};

$(function() {
  app.init();
});

// publish some globals for convenient debugging
window.$ = $;
window._ = require('underscore');
window.app = app;
window.React = React;
