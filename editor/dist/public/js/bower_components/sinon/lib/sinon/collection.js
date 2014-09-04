/**
 * Collections of stubs, spies and mocks.
 *
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2010-2013 Christian Johansen
 */

(function(e){function i(e){return e.fakes||(e.fakes=[]),e.fakes}function s(e,t){var n=i(e);for(var r=0,s=n.length;r<s;r+=1)typeof n[r][t]=="function"&&n[r][t]()}function o(e){var t=i(e),n=0;while(n<t.length)t.splice(n,1)}var t=typeof module!="undefined"&&module.exports,n=[].push,r=Object.prototype.hasOwnProperty;!e&&t&&(e=require("../sinon"));if(!e)return;var u={verify:function(){s(this,"verify")},restore:function(){s(this,"restore"),o(this)},verifyAndRestore:function(){var t;try{this.verify()}catch(n){t=n}this.restore();if(t)throw t},add:function(t){return n.call(i(this),t),t},spy:function(){return this.add(e.spy.apply(e,arguments))},stub:function(n,i,s){if(i){var o=n[i];if(typeof o!="function"){if(!r.call(n,i))throw new TypeError("Cannot stub non-existent own property "+i);return n[i]=s,this.add({restore:function(){n[i]=o}})}}if(!i&&!!n&&typeof n=="object"){var u=e.stub.apply(e,arguments);for(var a in u)typeof u[a]=="function"&&this.add(u[a]);return u}return this.add(e.stub.apply(e,arguments))},mock:function(){return this.add(e.mock.apply(e,arguments))},inject:function(t){var n=this;return t.spy=function(){return n.spy.apply(n,arguments)},t.stub=function(){return n.stub.apply(n,arguments)},t.mock=function(){return n.mock.apply(n,arguments)},t}};e.collection=u,typeof define=="function"&&define.amd?define(["module"],function(e){e.exports=u}):t&&(module.exports=u)})(typeof sinon=="object"&&sinon||null);