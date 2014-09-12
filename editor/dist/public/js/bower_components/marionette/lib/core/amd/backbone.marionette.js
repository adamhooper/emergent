// MarionetteJS (Backbone.Marionette)
// ----------------------------------
// v1.8.8
//
// Copyright (c)2014 Derick Bailey, Muted Solutions, LLC.
// Distributed under MIT license
//
// http://marionettejs.com

(function(e,t){if(typeof exports=="object"){var n=require("underscore"),r=require("backbone"),i=require("backbone.wreqr"),s=require("backbone.babysitter");module.exports=t(n,r,i,s)}else typeof define=="function"&&define.amd&&define(["underscore","backbone","backbone.wreqr","backbone.babysitter"],t)})(this,function(e,t){var n=function(e,t,n){function s(e,t){var n=new Error(e);throw n.name=t||"Error",n}var r={};t.Marionette=r,r.$=t.$;var i=Array.prototype.slice;return r.extend=t.Model.extend,r.getOption=function(e,t){if(!e||!t)return;var n;return e.options&&t in e.options&&e.options[t]!==undefined?n=e.options[t]:n=e[t],n},r.normalizeMethods=function(e){var t={},r;return n.each(e,function(e,i){r=e,n.isFunction(r)||(r=this[r]);if(!r)return;t[i]=r},this),t},r.normalizeUIKeys=function(e,t){if(typeof e=="undefined")return;return n.each(n.keys(e),function(n){var r=/@ui.[a-zA-Z_$0-9]*/g;n.match(r)&&(e[n.replace(r,function(e){return t[e.slice(4)]})]=e[n],delete e[n])}),e},r.actAsCollection=function(e,t){var r=["forEach","each","map","find","detect","filter","select","reject","every","all","some","any","include","contains","invoke","toArray","first","initial","rest","last","without","isEmpty","pluck"];n.each(r,function(r){e[r]=function(){var e=n.values(n.result(this,t)),i=[e].concat(n.toArray(arguments));return n[r].apply(n,i)}})},r.triggerMethod=function(){function t(e,t,n){return n.toUpperCase()}var e=/(^|:)(\w)/gi,r=function(r){var i="on"+r.replace(e,t),s=this[i];n.isFunction(this.trigger)&&this.trigger.apply(this,arguments);if(n.isFunction(s))return s.apply(this,n.tail(arguments))};return r}(),r.MonitorDOMRefresh=function(e){function t(e){e._isShown=!0,i(e)}function r(e){e._isRendered=!0,i(e)}function i(e){e._isShown&&e._isRendered&&s(e)&&n.isFunction(e.triggerMethod)&&e.triggerMethod("dom:refresh")}function s(t){return e.contains(t.el)}return function(e){e.listenTo(e,"show",function(){t(e)}),e.listenTo(e,"render",function(){r(e)})}}(document.documentElement),function(e){function t(e,t,r,i){var o=i.split(/\s+/);n.each(o,function(n){var i=e[n];i||s("Method '"+n+"' was configured as an event handler, but does not exist."),e.listenTo(t,r,i)})}function r(e,t,n,r){e.listenTo(t,n,r)}function i(e,t,r,i){var s=i.split(/\s+/);n.each(s,function(n){var i=e[n];e.stopListening(t,r,i)})}function o(e,t,n,r){e.stopListening(t,n,r)}function u(e,t,r,i,s){if(!t||!r)return;n.isFunction(r)&&(r=r.call(e)),n.each(r,function(r,o){n.isFunction(r)?i(e,t,o,r):s(e,t,o,r)})}e.bindEntityEvents=function(e,n,i){u(e,n,i,r,t)},e.unbindEntityEvents=function(e,t,n){u(e,t,n,o,i)}}(r),r.Callbacks=function(){this._deferred=r.$.Deferred(),this._callbacks=[]},n.extend(r.Callbacks.prototype,{add:function(e,t){this._callbacks.push({cb:e,ctx:t}),this._deferred.done(function(n,r){t&&(n=t),e.call(n,r)})},run:function(e,t){this._deferred.resolve(t,e)},reset:function(){var e=this._callbacks;this._deferred=r.$.Deferred(),this._callbacks=[],n.each(e,function(e){this.add(e.cb,e.ctx)},this)}}),r.Controller=function(e){this.triggerMethod=r.triggerMethod,this.options=e||{},n.isFunction(this.initialize)&&this.initialize(this.options)},r.Controller.extend=r.extend,n.extend(r.Controller.prototype,t.Events,{close:function(){this.stopListening();var e=Array.prototype.slice.call(arguments);this.triggerMethod.apply(this,["close"].concat(e)),this.off()}}),r.Region=function(e){this.options=e||{},this.el=r.getOption(this,"el"),this.el||s("An 'el' must be specified for a region.","NoElError");if(this.initialize){var t=Array.prototype.slice.apply(arguments);this.initialize.apply(this,t)}},n.extend(r.Region,{buildRegion:function(e,t){var r=n.isString(e),i=n.isString(e.selector),o=n.isUndefined(e.regionType),u=n.isFunction(e);!u&&!r&&!i&&s("Region must be specified as a Region type, a selector string or an object with selector property");var a,f;r&&(a=e),e.selector&&(a=e.selector,delete e.selector),u&&(f=e),!u&&o&&(f=t),e.regionType&&(f=e.regionType,delete e.regionType);if(r||u)e={};e.el=a;var l=new f(e);return e.parentEl&&(l.getEl=function(t){var r=e.parentEl;return n.isFunction(r)&&(r=r()),r.find(t)}),l}}),n.extend(r.Region.prototype,t.Events,{show:function(e,t){this.ensureEl();var i=t||{},s=e.isClosed||n.isUndefined(e.$el),o=e!==this.currentView,u=!!i.preventClose,a=!u&&o;return a&&this.close(),e.render(),r.triggerMethod.call(this,"before:show",e),n.isFunction(e.triggerMethod)?e.triggerMethod("before:show"):r.triggerMethod.call(e,"before:show"),(o||s)&&this.open(e),this.currentView=e,r.triggerMethod.call(this,"show",e),n.isFunction(e.triggerMethod)?e.triggerMethod("show"):r.triggerMethod.call(e,"show"),this},ensureEl:function(){if(!this.$el||this.$el.length===0)this.$el=this.getEl(this.el)},getEl:function(e){return r.$(e)},open:function(e){this.$el.empty().append(e.el)},close:function(){var e=this.currentView;if(!e||e.isClosed)return;e.close?e.close():e.remove&&e.remove(),r.triggerMethod.call(this,"close",e),delete this.currentView},attachView:function(e){this.currentView=e},reset:function(){this.close(),delete this.$el}}),r.Region.extend=r.extend,r.RegionManager=function(e){var t=e.Controller.extend({constructor:function(t){this._regions={},e.Controller.prototype.constructor.call(this,t)},addRegions:function(e,t){var r={};return n.each(e,function(e,i){n.isString(e)&&(e={selector:e}),e.selector&&(e=n.defaults({},e,t));var s=this.addRegion(i,e);r[i]=s},this),r},addRegion:function(t,r){var i,s=n.isObject(r),o=n.isString(r),u=!!r.selector;return o||s&&u?i=e.Region.buildRegion(r,e.Region):n.isFunction(r)?i=e.Region.buildRegion(r,e.Region):i=r,this._store(t,i),this.triggerMethod("region:add",t,i),i},get:function(e){return this._regions[e]},removeRegion:function(e){var t=this._regions[e];this._remove(e,t)},removeRegions:function(){n.each(this._regions,function(e,t){this._remove(t,e)},this)},closeRegions:function(){n.each(this._regions,function(e,t){e.close()},this)},close:function(){this.removeRegions(),e.Controller.prototype.close.apply(this,arguments)},_store:function(e,t){this._regions[e]=t,this._setLength()},_remove:function(e,t){t.close(),t.stopListening(),delete this._regions[e],this._setLength(),this.triggerMethod("region:remove",e,t)},_setLength:function(){this.length=n.size(this._regions)}});return e.actAsCollection(t.prototype,"_regions"),t}(r),r.TemplateCache=function(e){this.templateId=e},n.extend(r.TemplateCache,{templateCaches:{},get:function(e){var t=this.templateCaches[e];return t||(t=new r.TemplateCache(e),this.templateCaches[e]=t),t.load()},clear:function(){var e,t=i.call(arguments),n=t.length;if(n>0)for(e=0;e<n;e++)delete this.templateCaches[t[e]];else this.templateCaches={}}}),n.extend(r.TemplateCache.prototype,{load:function(){if(this.compiledTemplate)return this.compiledTemplate;var e=this.loadTemplate(this.templateId);return this.compiledTemplate=this.compileTemplate(e),this.compiledTemplate},loadTemplate:function(e){var t=r.$(e).html();return(!t||t.length===0)&&s("Could not find template: '"+e+"'","NoTemplateError"),t},compileTemplate:function(e){return n.template(e)}}),r.Renderer={render:function(e,t){e||s("Cannot render the template since it's false, null or undefined.","TemplateNotFoundError");var n;return typeof e=="function"?n=e:n=r.TemplateCache.get(e),n(t)}},r.View=t.View.extend({constructor:function(e){n.bindAll(this,"render"),this.options=n.extend({},n.result(this,"options"),n.isFunction(e)?e.call(this):e),this.events=this.normalizeUIKeys(n.result(this,"events")),n.isObject(this.behaviors)&&new r.Behaviors(this),t.View.prototype.constructor.apply(this,arguments),r.MonitorDOMRefresh(this),this.listenTo(this,"show",this.onShowCalled)},triggerMethod:r.triggerMethod,normalizeMethods:r.normalizeMethods,getTemplate:function(){return r.getOption(this,"template")},mixinTemplateHelpers:function(e){e=e||{};var t=r.getOption(this,"templateHelpers");return n.isFunction(t)&&(t=t.call(this)),n.extend(e,t)},normalizeUIKeys:function(e){var t=n.result(this,"ui");return r.normalizeUIKeys(e,t)},configureTriggers:function(){if(!this.triggers)return;var e={},t=this.normalizeUIKeys(n.result(this,"triggers"));return n.each(t,function(t,r){var i=n.isObject(t),s=i?t.event:t;e[r]=function(e){if(e){var n=e.preventDefault,r=e.stopPropagation,o=i?t.preventDefault:n,u=i?t.stopPropagation:r;o&&n&&n.apply(e),u&&r&&r.apply(e)}var a={view:this,model:this.model,collection:this.collection};this.triggerMethod(s,a)}},this),e},delegateEvents:function(e){this._delegateDOMEvents(e),r.bindEntityEvents(this,this.model,r.getOption(this,"modelEvents")),r.bindEntityEvents(this,this.collection,r.getOption(this,"collectionEvents"))},_delegateDOMEvents:function(e){e=e||this.events,n.isFunction(e)&&(e=e.call(this));var r={},i=n.result(this,"behaviorEvents")||{},s=this.configureTriggers();n.extend(r,i,e,s),t.View.prototype.delegateEvents.call(this,r)},undelegateEvents:function(){var e=Array.prototype.slice.call(arguments);t.View.prototype.undelegateEvents.apply(this,e),r.unbindEntityEvents(this,this.model,r.getOption(this,"modelEvents")),r.unbindEntityEvents(this,this.collection,r.getOption(this,"collectionEvents"))},onShowCalled:function(){},close:function(){if(this.isClosed)return;var e=Array.prototype.slice.call(arguments),t=this.triggerMethod.apply(this,["before:close"].concat(e));if(t===!1)return;this.isClosed=!0,this.triggerMethod.apply(this,["close"].concat(e)),this.unbindUIElements(),this.remove()},bindUIElements:function(){if(!this.ui)return;this._uiBindings||(this._uiBindings=this.ui);var e=n.result(this,"_uiBindings");this.ui={},n.each(n.keys(e),function(t){var n=e[t];this.ui[t]=this.$(n)},this)},unbindUIElements:function(){if(!this.ui||!this._uiBindings)return;n.each(this.ui,function(e,t){delete this.ui[t]},this),this.ui=this._uiBindings,delete this._uiBindings}}),r.ItemView=r.View.extend({constructor:function(){r.View.prototype.constructor.apply(this,arguments)},serializeData:function(){var e={};return this.model?e=this.model.toJSON():this.collection&&(e={items:this.collection.toJSON()}),e},render:function(){this.isClosed=!1,this.triggerMethod("before:render",this),this.triggerMethod("item:before:render",this);var e=this.serializeData();e=this.mixinTemplateHelpers(e);var t=this.getTemplate(),n=r.Renderer.render(t,e);return this.$el.html(n),this.bindUIElements(),this.triggerMethod("render",this),this.triggerMethod("item:rendered",this),this},close:function(){if(this.isClosed)return;this.triggerMethod("item:before:close"),r.View.prototype.close.apply(this,arguments),this.triggerMethod("item:closed")}}),r.CollectionView=r.View.extend({itemViewEventPrefix:"itemview",constructor:function(e){this._initChildViewStorage(),r.View.prototype.constructor.apply(this,arguments),this._initialEvents(),this.initRenderBuffer()},initRenderBuffer:function(){this.elBuffer=document.createDocumentFragment(),this._bufferedChildren=[]},startBuffering:function(){this.initRenderBuffer(),this.isBuffering=!0},endBuffering:function(){this.isBuffering=!1,this.appendBuffer(this,this.elBuffer),this._triggerShowBufferedChildren(),this.initRenderBuffer()},_triggerShowBufferedChildren:function(){this._isShown&&(n.each(this._bufferedChildren,function(e){n.isFunction(e.triggerMethod)?e.triggerMethod("show"):r.triggerMethod.call(e,"show")}),this._bufferedChildren=[])},_initialEvents:function(){this.collection&&(this.listenTo(this.collection,"add",this.addChildView),this.listenTo(this.collection,"remove",this.removeItemView),this.listenTo(this.collection,"reset",this.render))},addChildView:function(e,t,n){this.closeEmptyView();var r=this.getItemView(e),i=this.collection.indexOf(e);this.addItemView(e,r,i)},onShowCalled:function(){this.children.each(function(e){n.isFunction(e.triggerMethod)?e.triggerMethod("show"):r.triggerMethod.call(e,"show")})},triggerBeforeRender:function(){this.triggerMethod("before:render",this),this.triggerMethod("collection:before:render",this)},triggerRendered:function(){this.triggerMethod("render",this),this.triggerMethod("collection:rendered",this)},render:function(){return this.isClosed=!1,this.triggerBeforeRender(),this._renderChildren(),this.triggerRendered(),this},_renderChildren:function(){this.startBuffering(),this.closeEmptyView(),this.closeChildren(),this.isEmpty(this.collection)?this.showEmptyView():this.showCollection(),this.endBuffering()},showCollection:function(){var e;this.collection.each(function(t,n){e=this.getItemView(t),this.addItemView(t,e,n)},this)},showEmptyView:function(){var e=this.getEmptyView();if(e&&!this._showingEmptyView){this._showingEmptyView=!0;var n=new t.Model;this.addItemView(n,e,0)}},closeEmptyView:function(){this._showingEmptyView&&(this.closeChildren(),delete this._showingEmptyView)},getEmptyView:function(){return r.getOption(this,"emptyView")},getItemView:function(e){var t=r.getOption(this,"itemView");return t||s("An `itemView` must be specified","NoItemViewError"),t},addItemView:function(e,t,i){var s=r.getOption(this,"itemViewOptions");n.isFunction(s)&&(s=s.call(this,e,i));var o=this.buildItemView(e,t,s);return this.addChildViewEventForwarding(o),this.triggerMethod("before:item:added",o),this.children.add(o),this.renderItemView(o,i),this._isShown&&!this.isBuffering&&(n.isFunction(o.triggerMethod)?o.triggerMethod("show"):r.triggerMethod.call(o,"show")),this.triggerMethod("after:item:added",o),o},addChildViewEventForwarding:function(e){var t=r.getOption(this,"itemViewEventPrefix");this.listenTo(e,"all",function(){var s=i.call(arguments),o=s[0],u=this.normalizeMethods(this.getItemEvents());s[0]=t+":"+o,s.splice(1,0,e),typeof u!="undefined"&&n.isFunction(u[o])&&u[o].apply(this,s),r.triggerMethod.apply(this,s)},this)},getItemEvents:function(){return n.isFunction(this.itemEvents)?this.itemEvents.call(this):this.itemEvents},renderItemView:function(e,t){e.render(),this.appendHtml(this,e,t)},buildItemView:function(e,t,r){var i=n.extend({model:e},r);return new t(i)},removeItemView:function(e){var t=this.children.findByModel(e);this.removeChildView(t),this.checkEmpty()},removeChildView:function(e){e&&(e.close?e.close():e.remove&&e.remove(),this.stopListening(e),this.children.remove(e)),this.triggerMethod("item:removed",e)},isEmpty:function(e){return!this.collection||this.collection.length===0},checkEmpty:function(){this.isEmpty(this.collection)&&this.showEmptyView()},appendBuffer:function(e,t){e.$el.append(t)},appendHtml:function(e,t,n){e.isBuffering?(e.elBuffer.appendChild(t.el),e._bufferedChildren.push(t)):e.$el.append(t.el)},_initChildViewStorage:function(){this.children=new t.ChildViewContainer},close:function(){if(this.isClosed)return;this.triggerMethod("collection:before:close"),this.closeChildren(),this.triggerMethod("collection:closed"),r.View.prototype.close.apply(this,arguments)},closeChildren:function(){this.children.each(function(e){this.removeChildView(e)},this),this.checkEmpty()}}),r.CompositeView=r.CollectionView.extend({constructor:function(){r.CollectionView.prototype.constructor.apply(this,arguments)},_initialEvents:function(){this.once("render",function(){this.collection&&(this.listenTo(this.collection,"add",this.addChildView),this.listenTo(this.collection,"remove",this.removeItemView),this.listenTo(this.collection,"reset",this._renderChildren))})},getItemView:function(e){var t=r.getOption(this,"itemView")||this.constructor;return t||s("An `itemView` must be specified","NoItemViewError"),t},serializeData:function(){var e={};return this.model&&(e=this.model.toJSON()),e},render:function(){this.isRendered=!0,this.isClosed=!1,this.resetItemViewContainer(),this.triggerBeforeRender();var e=this.renderModel();return this.$el.html(e),this.bindUIElements(),this.triggerMethod("composite:model:rendered"),this._renderChildren(),this.triggerMethod("composite:rendered"),this.triggerRendered(),this},_renderChildren:function(){this.isRendered&&(this.triggerMethod("composite:collection:before:render"),r.CollectionView.prototype._renderChildren.call(this),this.triggerMethod("composite:collection:rendered"))},renderModel:function(){var e={};e=this.serializeData(),e=this.mixinTemplateHelpers(e);var t=this.getTemplate();return r.Renderer.render(t,e)},appendBuffer:function(e,t){var n=this.getItemViewContainer(e);n.append(t)},appendHtml:function(e,t,n){if(e.isBuffering)e.elBuffer.appendChild(t.el),e._bufferedChildren.push(t);else{var r=this.getItemViewContainer(e);r.append(t.el)}},getItemViewContainer:function(e){if("$itemViewContainer"in e)return e.$itemViewContainer;var t,i=r.getOption(e,"itemViewContainer");if(i){var o=n.isFunction(i)?i.call(e):i;o.charAt(0)==="@"&&e.ui?t=e.ui[o.substr(4)]:t=e.$(o),t.length<=0&&s("The specified `itemViewContainer` was not found: "+e.itemViewContainer,"ItemViewContainerMissingError")}else t=e.$el;return e.$itemViewContainer=t,t},resetItemViewContainer:function(){this.$itemViewContainer&&delete this.$itemViewContainer}}),r.Layout=r.ItemView.extend({regionType:r.Region,constructor:function(e){e=e||{},this._firstRender=!0,this._initializeRegions(e),r.ItemView.prototype.constructor.call(this,e)},render:function(){return this.isClosed&&this._initializeRegions(),this._firstRender?this._firstRender=!1:this.isClosed||this._reInitializeRegions(),r.ItemView.prototype.render.apply(this,arguments)},close:function(){if(this.isClosed)return;this.regionManager.close(),r.ItemView.prototype.close.apply(this,arguments)},addRegion:function(e,t){var n={};return n[e]=t,this._buildRegions(n)[e]},addRegions:function(e){return this.regions=n.extend({},this.regions,e),this._buildRegions(e)},removeRegion:function(e){return delete this.regions[e],this.regionManager.removeRegion(e)},getRegion:function(e){return this.regionManager.get(e)},_buildRegions:function(e){var t=this,n={regionType:r.getOption(this,"regionType"),parentEl:function(){return t.$el}};return this.regionManager.addRegions(e,n)},_initializeRegions:function(e){var t;this._initRegionManager(),n.isFunction(this.regions)?t=this.regions(e):t=this.regions||{},this.addRegions(t)},_reInitializeRegions:function(){this.regionManager.closeRegions(),this.regionManager.each(function(e){e.reset()})},_initRegionManager:function(){this.regionManager=new r.RegionManager,this.listenTo(this.regionManager,"region:add",function(e,t){this[e]=t,this.trigger("region:add",e,t)}),this.listenTo(this.regionManager,"region:remove",function(e,t){delete this[e],this.trigger("region:remove",e,t)})}}),r.Behavior=function(e,t){function n(t,n){this.view=n,this.defaults=e.result(this,"defaults")||{},this.options=e.extend({},this.defaults,t),this.$=function(){return this.view.$.apply(this.view,arguments)},this.initialize.apply(this,arguments)}return e.extend(n.prototype,t.Events,{initialize:function(){},close:function(){this.stopListening()},triggerMethod:r.triggerMethod}),n.extend=r.extend,n}(n,t),r.Behaviors=function(e,t){function n(e){this.behaviors=n.parseBehaviors(e,t.result(e,"behaviors")),n.wrap(e,this.behaviors,["bindUIElements","unbindUIElements","delegateEvents","undelegateEvents","behaviorEvents","triggerMethod","setElement","close"])}var r={setElement:function(e,n){e.apply(this,t.tail(arguments,2)),t.each(n,function(e){e.$el=this.$el},this)},close:function(e,n){var r=t.tail(arguments,2);e.apply(this,r),t.invoke(n,"close",r)},bindUIElements:function(e,n){e.apply(this),t.invoke(n,e)},unbindUIElements:function(e,n){e.apply(this),t.invoke(n,e)},triggerMethod:function(e,n){var r=t.tail(arguments,2);e.apply(this,r),t.each(n,function(t){e.apply(t,r)})},delegateEvents:function(n,r){var i=t.tail(arguments,2);n.apply(this,i),t.each(r,function(t){e.bindEntityEvents(t,this.model,e.getOption(t,"modelEvents")),e.bindEntityEvents(t,this.collection,e.getOption(t,"collectionEvents"))},this)},undelegateEvents:function(n,r){var i=t.tail(arguments,2);n.apply(this,i),t.each(r,function(t){e.unbindEntityEvents(t,this.model,e.getOption(t,"modelEvents")),e.unbindEntityEvents(t,this.collection,e.getOption(t,"collectionEvents"))},this)},behaviorEvents:function(n,r){var i={},s=t.result(this,"ui");return t.each(r,function(n,r){var o={},u=t.clone(t.result(n,"events"))||{},a=t.result(n,"ui"),f=t.extend({},s,a);u=e.normalizeUIKeys(u,f),t.each(t.keys(u),function(e){var i=(new Array(r+2)).join(" "),s=e+i,a=t.isFunction(u[e])?u[e]:n[u[e]];o[s]=t.bind(a,n)}),i=t.extend(i,o)}),i}};return t.extend(n,{behaviorsLookup:function(){throw new Error("You must define where your behaviors are stored. See https://github.com/marionettejs/backbone.marionette/blob/master/docs/marionette.behaviors.md#behaviorslookup")},getBehaviorClass:function(e,r){return e.behaviorClass?e.behaviorClass:t.isFunction(n.behaviorsLookup)?n.behaviorsLookup.apply(this,arguments)[r]:n.behaviorsLookup[r]},parseBehaviors:function(e,r){return t.map(r,function(t,r){var i=n.getBehaviorClass(t,r);return new i(t,e)})},wrap:function(e,n,i){t.each(i,function(i){e[i]=t.partial(r[i],e[i],n)})}}),n}(r,n),r.AppRouter=t.Router.extend({constructor:function(e){t.Router.prototype.constructor.apply(this,arguments),this.options=e||{};var n=r.getOption(this,"appRoutes"),i=this._getController();this.processAppRoutes(i,n),this.on("route",this._processOnRoute,this)},appRoute:function(e,t){var n=this._getController();this._addAppRoute(n,e,t)},_processOnRoute:function(e,t){var r=n.invert(this.appRoutes)[e];n.isFunction(this.onRoute)&&this.onRoute(e,r,t)},processAppRoutes:function(e,t){if(!t)return;var r=n.keys(t).reverse();n.each(r,function(n){this._addAppRoute(e,n,t[n])},this)},_getController:function(){return r.getOption(this,"controller")},_addAppRoute:function(e,t,r){var i=e[r];i||s("Method '"+r+"' was not found on the controller"),this.route(t,r,n.bind(i,e))}}),r.Application=function(e){this._initRegionManager(),this._initCallbacks=new r.Callbacks,this.vent=new t.Wreqr.EventAggregator,this.commands=new t.Wreqr.Commands,this.reqres=new t.Wreqr.RequestResponse,this.submodules={},n.extend(this,e),this.triggerMethod=r.triggerMethod},n.extend(r.Application.prototype,t.Events,{execute:function(){this.commands.execute.apply(this.commands,arguments)},request:function(){return this.reqres.request.apply(this.reqres,arguments)},addInitializer:function(e){this._initCallbacks.add(e)},start:function(e){this.triggerMethod("initialize:before",e),this._initCallbacks.run(e,this),this.triggerMethod("initialize:after",e),this.triggerMethod("start",e)},addRegions:function(e){return this._regionManager.addRegions(e)},closeRegions:function(){this._regionManager.closeRegions()},removeRegion:function(e){this._regionManager.removeRegion(e)},getRegion:function(e){return this._regionManager.get(e)},module:function(e,t){var n=r.Module.getClass(t),s=i.call(arguments);return s.unshift(this),n.create.apply(n,s)},_initRegionManager:function(){this._regionManager=new r.RegionManager,this.listenTo(this._regionManager,"region:add",function(e,t){this[e]=t}),this.listenTo(this._regionManager,"region:remove",function(e,t){delete this[e]})}}),r.Application.extend=r.extend,r.Module=function(e,t,i){this.moduleName=e,this.options=n.extend({},this.options,i),this.initialize=i.initialize||this.initialize,this.submodules={},this._setupInitializersAndFinalizers(),this.app=t,this.startWithParent=!0,this.triggerMethod=r.triggerMethod,n.isFunction(this.initialize)&&this.initialize(this.options,e,t)},r.Module.extend=r.extend,n.extend(r.Module.prototype,t.Events,{initialize:function(){},addInitializer:function(e){this._initializerCallbacks.add(e)},addFinalizer:function(e){this._finalizerCallbacks.add(e)},start:function(e){if(this._isInitialized)return;n.each(this.submodules,function(t){t.startWithParent&&t.start(e)}),this.triggerMethod("before:start",e),this._initializerCallbacks.run(e,this),this._isInitialized=!0,this.triggerMethod("start",e)},stop:function(){if(!this._isInitialized)return;this._isInitialized=!1,r.triggerMethod.call(this,"before:stop"),n.each(this.submodules,function(e){e.stop()}),this._finalizerCallbacks.run(undefined,this),this._initializerCallbacks.reset(),this._finalizerCallbacks.reset(),r.triggerMethod.call(this,"stop")},addDefinition:function(e,t){this._runModuleDefinition(e,t)},_runModuleDefinition:function(e,i){if(!e)return;var s=n.flatten([this,this.app,t,r,r.$,n,i]);e.apply(this,s)},_setupInitializersAndFinalizers:function(){this._initializerCallbacks=new r.Callbacks,this._finalizerCallbacks=new r.Callbacks}}),n.extend(r.Module,{create:function(e,t,r){var s=e,o=i.call(arguments);o.splice(0,3),t=t.split(".");var u=t.length,a=[];return a[u-1]=r,n.each(t,function(t,n){var i=s;s=this._getModule(i,t,e,r),this._addModuleDefinition(i,s,a[n],o)},this),s},_getModule:function(e,t,r,i,s){var o=n.extend({},i),u=this.getClass(i),a=e[t];return a||(a=new u(t,r,o),e[t]=a,e.submodules[t]=a),a},getClass:function(e){var t=r.Module;return e?e.prototype instanceof t?e:e.moduleClass||t:t},_addModuleDefinition:function(e,t,n,r){var i=this._getDefine(n),s=this._getStartWithParent(n,t);i&&t.addDefinition(i,r),this._addStartWithParent(e,t,s)},_getStartWithParent:function(e,t){var i;return n.isFunction(e)&&e.prototype instanceof r.Module?(i=t.constructor.prototype.startWithParent,n.isUndefined(i)?!0:i):n.isObject(e)?(i=e.startWithParent,n.isUndefined(i)?!0:i):!0},_getDefine:function(e){return!n.isFunction(e)||e.prototype instanceof r.Module?n.isObject(e)?e.define:null:e},_addStartWithParent:function(e,t,n){t.startWithParent=t.startWithParent&&n;if(!t.startWithParent||!!t.startWithParentIsConfigured)return;t.startWithParentIsConfigured=!0,e.addInitializer(function(e){t.startWithParent&&t.start(e)})}}),r}(this,t,e);return t.Marionette});