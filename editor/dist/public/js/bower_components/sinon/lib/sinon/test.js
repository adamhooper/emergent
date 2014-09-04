/**
 * Test function, sandboxes fakes
 *
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2010-2013 Christian Johansen
 */

(function(e){function n(t){var n=typeof t;if(n!="function")throw new TypeError("sinon.test needs to wrap a test function, got "+n);return function(){var n=e.getConfig(e.config);n.injectInto=n.injectIntoThis&&this||n.injectInto;var r=e.sandbox.create(n),i,s,o=Array.prototype.slice.call(arguments).concat(r.args);try{s=t.apply(this,o)}catch(u){i=u}if(typeof i!="undefined")throw r.restore(),i;return r.verifyAndRestore(),s}}var t=typeof module!="undefined"&&module.exports;!e&&t&&(e=require("../sinon"));if(!e)return;n.config={injectIntoThis:!0,injectInto:null,properties:["spy","stub","mock","clock","server","requests"],useFakeTimers:!0,useFakeServer:!0},e.test=n,typeof define=="function"&&define.amd?define(["module"],function(e){e.exports=n}):t&&(module.exports=n)})(typeof sinon=="object"&&sinon||null);