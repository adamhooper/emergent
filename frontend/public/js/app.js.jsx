/** @jsx React.DOM */

var $ = require('jquery');
var React = require('react');
var Router = require('react-router');
var Route = Router.Route;
var Routes = Router.Routes;
var DefaultRoute = Router.DefaultRoute;
var Root = require('./components/root.js.jsx');

var app = {
  init: function() {
    this.claims = new this.collections.Claims();
    this.claims.url = 'http://api.emergent.info/claims'
    this.claims.fetch().done(function() {
      this.claims.sort();
      React.renderComponent(
        <Routes location="history">
          <Route path="/" handler={Root} claims={this.claims}>
            <DefaultRoute name="claims" handler={this.components.Claims}/>
            <Route name="about" path="about" handler={this.components.About}/>
            <Route name="claim" path=":slug" handler={this.components.Claim}/>
            <Route name="article" path=":slug/articles/:articleId" handler={this.components.Article}/>
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
    Article: require('./components/article.js.jsx'),
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
