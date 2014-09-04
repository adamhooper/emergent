// Backbone.Wreqr (Backbone.Marionette)
// ----------------------------------
// v1.3.1
//
// Copyright (c)2014 Derick Bailey, Muted Solutions, LLC.
// Distributed under MIT license
//
// http://github.com/marionettejs/backbone.wreqr

(function(e,t){if(typeof define=="function"&&define.amd)define(["backbone","underscore"],function(e,n){return t(e,n)});else if(typeof exports!="undefined"){var n=require("backbone"),r=require("underscore");module.exports=t(n,r)}else t(e.Backbone,e._)})(this,function(e,t){var n=e.Wreqr,r=e.Wreqr={};return e.Wreqr.VERSION="1.3.1",e.Wreqr.noConflict=function(){return e.Wreqr=n,this},r.Handlers=function(e,t){var n=function(e){this.options=e,this._wreqrHandlers={},t.isFunction(this.initialize)&&this.initialize(e)};return n.extend=e.Model.extend,t.extend(n.prototype,e.Events,{setHandlers:function(e){t.each(e,function(e,n){var r=null;t.isObject(e)&&!t.isFunction(e)&&(r=e.context,e=e.callback),this.setHandler(n,e,r)},this)},setHandler:function(e,t,n){var r={callback:t,context:n};this._wreqrHandlers[e]=r,this.trigger("handler:add",e,t,n)},hasHandler:function(e){return!!this._wreqrHandlers[e]},getHandler:function(e){var t=this._wreqrHandlers[e];if(!t)return;return function(){var e=Array.prototype.slice.apply(arguments);return t.callback.apply(t.context,e)}},removeHandler:function(e){delete this._wreqrHandlers[e]},removeAllHandlers:function(){this._wreqrHandlers={}}}),n}(e,t),r.CommandStorage=function(){var n=function(e){this.options=e,this._commands={},t.isFunction(this.initialize)&&this.initialize(e)};return t.extend(n.prototype,e.Events,{getCommands:function(e){var t=this._commands[e];return t||(t={command:e,instances:[]},this._commands[e]=t),t},addCommand:function(e,t){var n=this.getCommands(e);n.instances.push(t)},clearCommands:function(e){var t=this.getCommands(e);t.instances=[]}}),n}(),r.Commands=function(e){return e.Handlers.extend({storageType:e.CommandStorage,constructor:function(t){this.options=t||{},this._initializeStorage(this.options),this.on("handler:add",this._executeCommands,this);var n=Array.prototype.slice.call(arguments);e.Handlers.prototype.constructor.apply(this,n)},execute:function(e,t){e=arguments[0],t=Array.prototype.slice.call(arguments,1),this.hasHandler(e)?this.getHandler(e).apply(this,t):this.storage.addCommand(e,t)},_executeCommands:function(e,n,r){var i=this.storage.getCommands(e);t.each(i.instances,function(e){n.apply(r,e)}),this.storage.clearCommands(e)},_initializeStorage:function(e){var n,r=e.storageType||this.storageType;t.isFunction(r)?n=new r:n=r,this.storage=n}})}(r),r.RequestResponse=function(e){return e.Handlers.extend({request:function(){var e=arguments[0],t=Array.prototype.slice.call(arguments,1);if(this.hasHandler(e))return this.getHandler(e).apply(this,t)}})}(r),r.EventAggregator=function(e,t){var n=function(){};return n.extend=e.Model.extend,t.extend(n.prototype,e.Events),n}(e,t),r.Channel=function(n){var r=function(t){this.vent=new e.Wreqr.EventAggregator,this.reqres=new e.Wreqr.RequestResponse,this.commands=new e.Wreqr.Commands,this.channelName=t};return t.extend(r.prototype,{reset:function(){return this.vent.off(),this.vent.stopListening(),this.reqres.removeAllHandlers(),this.commands.removeAllHandlers(),this},connectEvents:function(e,t){return this._connect("vent",e,t),this},connectCommands:function(e,t){return this._connect("commands",e,t),this},connectRequests:function(e,t){return this._connect("reqres",e,t),this},_connect:function(e,n,r){if(!n)return;r=r||this;var i=e==="vent"?"on":"setHandler";t.each(n,function(n,s){this[e][i](s,t.bind(n,r))},this)}}),r}(r),r.radio=function(e){var n=function(){this._channels={},this.vent={},this.commands={},this.reqres={},this._proxyMethods()};t.extend(n.prototype,{channel:function(e){if(!e)throw new Error("Channel must receive a name");return this._getChannel(e)},_getChannel:function(t){var n=this._channels[t];return n||(n=new e.Channel(t),this._channels[t]=n),n},_proxyMethods:function(){t.each(["vent","commands","reqres"],function(e){t.each(r[e],function(t){this[e][t]=i(this,e,t)},this)},this)}});var r={vent:["on","off","trigger","once","stopListening","listenTo","listenToOnce"],commands:["execute","setHandler","setHandlers","removeHandler","removeAllHandlers"],reqres:["request","setHandler","setHandlers","removeHandler","removeAllHandlers"]},i=function(e,t,n){return function(r){var i=e._getChannel(r)[t],s=Array.prototype.slice.call(arguments,1);return i[n].apply(i,s)}};return new n}(r),e.Wreqr});