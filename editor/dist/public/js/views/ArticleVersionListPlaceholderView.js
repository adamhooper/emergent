(function(){var e={}.hasOwnProperty,t=function(t,n){function i(){this.constructor=t}for(var r in n)e.call(n,r)&&(t[r]=n[r]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t};define(["marionette"],function(e){var n;return n=function(e){function n(){return n.__super__.constructor.apply(this,arguments)}return t(n,e),n.prototype.className="article-version-list-placeholder",n.prototype.template=function(){return'<p class="help">Click an article on the left to enter information about it here.</p>'},n}(e.ItemView)})}).call(this);