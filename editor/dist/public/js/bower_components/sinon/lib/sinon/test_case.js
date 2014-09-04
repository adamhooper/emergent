/**
 * Test case, sandboxes all test functions
 *
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2010-2013 Christian Johansen
 */

(function(e){function n(e,t,n){return function(){t&&t.apply(this,arguments);var r,i;try{i=e.apply(this,arguments)}catch(s){r=s}n&&n.apply(this,arguments);if(r)throw r;return i}}function r(t,r){if(!t||typeof t!="object")throw new TypeError("sinon.testCase needs an object with test functions");r=r||"test";var i=new RegExp("^"+r),s={},o,u,a,f=t.setUp,l=t.tearDown;for(o in t)if(t.hasOwnProperty(o)){u=t[o];if(/^(setUp|tearDown)$/.test(o))continue;if(typeof u=="function"&&i.test(o)){a=u;if(f||l)a=n(u,f,l);s[o]=e.test(a)}else s[o]=t[o]}return s}var t=typeof module!="undefined"&&module.exports;!e&&t&&(e=require("../sinon"));if(!e||!Object.prototype.hasOwnProperty)return;e.testCase=r,typeof define=="function"&&define.amd?define(["module"],function(e){e.exports=r}):t&&(module.exports=r)})(typeof sinon=="object"&&sinon||null);