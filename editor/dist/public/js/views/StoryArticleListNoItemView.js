(function(){var e={}.hasOwnProperty,t=function(t,n){function i(){this.constructor=t}for(var r in n)e.call(n,r)&&(t[r]=n[r]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t};define(["underscore","marionette"],function(e,n){var r;return r=function(n){function r(){return r.__super__.constructor.apply(this,arguments)}return t(r,n),r.prototype.tagName="li",r.prototype.className="no-article",r.prototype.template=e.template("<p>You have not added any articles to this story yet.</p>"),r}(n.ItemView)})}).call(this);