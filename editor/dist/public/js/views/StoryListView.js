(function(){var e={}.hasOwnProperty,t=function(t,n){function i(){this.constructor=t}for(var r in n)e.call(n,r)&&(t[r]=n[r]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t};define(["marionette","views/StoryListItemView","views/StoryListNoItemView"],function(e,n,r){var i;return i=function(e){function i(){return i.__super__.constructor.apply(this,arguments)}return t(i,e),i.prototype.tagName="ul",i.prototype.className="story-list",i.prototype.itemView=n,i.prototype.emptyView=r,i.prototype.initialize=function(){var e,t,n,r,i,s;t=function(e){return function(t){return e.on("itemview:"+t,function(n){return e.trigger(t,n.model.id)})}}(this),i=["click","delete"],s=[];for(n=0,r=i.length;n<r;n++)e=i[n],s.push(t(e));return s},i}(e.CollectionView)})}).call(this);