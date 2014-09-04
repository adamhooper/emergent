/**
 * Add-on for sinon.fakeServer that automatically handles a fake timer along with
 * the FakeXMLHttpRequest. The direct inspiration for this add-on is jQuery
 * 1.3.x, which does not use xhr object's onreadystatehandler at all - instead,
 * it polls the object for completion with setInterval. Dispite the direct
 * motivation, there is nothing jQuery-specific in this file, so it can be used
 * in any environment where the ajax implementation depends on setInterval or
 * setTimeout.
 *
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2010-2013 Christian Johansen
 */

(function(){function e(){}e.prototype=sinon.fakeServer,sinon.fakeServerWithClock=new e,sinon.fakeServerWithClock.addRequest=function(t){if(t.async){typeof setTimeout.clock=="object"?this.clock=setTimeout.clock:(this.clock=sinon.useFakeTimers(),this.resetClock=!0);if(!this.longestTimeout){var n=this.clock.setTimeout,r=this.clock.setInterval,i=this;this.clock.setTimeout=function(e,t){return i.longestTimeout=Math.max(t,i.longestTimeout||0),n.apply(this,arguments)},this.clock.setInterval=function(e,t){return i.longestTimeout=Math.max(t,i.longestTimeout||0),r.apply(this,arguments)}}}return sinon.fakeServer.addRequest.call(this,t)},sinon.fakeServerWithClock.respond=function(){var t=sinon.fakeServer.respond.apply(this,arguments);return this.clock&&(this.clock.tick(this.longestTimeout||0),this.longestTimeout=0,this.resetClock&&(this.clock.restore(),this.resetClock=!1)),t},sinon.fakeServerWithClock.restore=function(){return this.clock&&this.clock.restore(),sinon.fakeServer.restore.apply(this,arguments)}})();