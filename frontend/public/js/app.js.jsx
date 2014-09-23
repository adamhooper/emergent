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
      React.renderComponent(
        <Routes location="history">
          <Route path="/" handler={Root}>
            <DefaultRoute name="claims" handler={this.components.Claims} claims={this.claims}/>
            <Route name="about" path="about" handler={this.components.About}/>
            <Route name="claim" path=":slug" handler={this.components.Claim} claims={this.claims}/>
            <Route name="article" path=":slug/articles/:articleId" handler={this.components.Article} claims={this.claims}/>
          </Route>
        </Routes>
      , document.body);
    }.bind(this));
  },

  components: {
    Claim: require('./components/claim.js.jsx'),
    Claims: require('./components/claims.js.jsx'),
    Article: require('./components/article.js.jsx'),
    About: require('./components/about.js.jsx')
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
