/*!
 * assertion-error
 * Copyright(c) 2013 Jake Luer <jake@qualiancy.com>
 * MIT Licensed
 */

/*!
 * Return a function that will copy properties from
 * one object to another excluding any originally
 * listed. Returned function will create a new `{}`.
 *
 * @param {String} excluded properties ...
 * @return {Function}
 */

/*!
 * Primary Exports
 */

/*!
 * Inherit from Error.prototype
 */

/*!
 * Statically set name
 */

/*!
 * Ensure correct constructor
 */

/*!
 * type-detect
 * Copyright(c) 2013 jake luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Detectable javascript natives
 */

/*!
 * deep-eql
 * Copyright(c) 2013 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Module dependencies
 */

/*!
 * Buffer.isBuffer browser shim
 */

/*!
 * Primary Export
 */

/*!
 * Strict (egal) equality test. Ensures that NaN always
 * equals NaN and `-0` does not equal `+0`.
 *
 * @param {Mixed} a
 * @param {Mixed} b
 * @return {Boolean} equal match
 */

/*!
 * Compare the types of two given objects and
 * return if they are equal. Note that an Array
 * has a type of `array` (not `object`) and arguments
 * have a type of `arguments` (not `array`/`object`).
 *
 * @param {Mixed} a
 * @param {Mixed} b
 * @return {Boolean} result
 */

/*!
 * Compare two Date objects by asserting that
 * the time values are equal using `saveValue`.
 *
 * @param {Date} a
 * @param {Date} b
 * @return {Boolean} result
 */

/*!
 * Compare two regular expressions by converting them
 * to string and checking for `sameValue`.
 *
 * @param {RegExp} a
 * @param {RegExp} b
 * @return {Boolean} result
 */

/*!
 * Assert deep equality of two `arguments` objects.
 * Unfortunately, these must be sliced to arrays
 * prior to test to ensure no bad behavior.
 *
 * @param {Arguments} a
 * @param {Arguments} b
 * @param {Array} memoize (optional)
 * @return {Boolean} result
 */

/*!
 * Get enumerable properties of a given object.
 *
 * @param {Object} a
 * @return {Array} property names
 */

/*!
 * Simple equality for flat iterable objects
 * such as Arrays or Node.js buffers.
 *
 * @param {Iterable} a
 * @param {Iterable} b
 * @return {Boolean} result
 */

/*!
 * Extension to `iterableEqual` specifically
 * for Node.js Buffers.
 *
 * @param {Buffer} a
 * @param {Mixed} b
 * @return {Boolean} result
 */

/*!
 * Block for `objectEqual` ensuring non-existing
 * values don't get in.
 *
 * @param {Mixed} object
 * @return {Boolean} result
 */

/*!
 * Recursively check the equality of two objects.
 * Once basic sameness has been established it will
 * defer to `deepEqual` for each enumerable key
 * in the object.
 *
 * @param {Mixed} a
 * @param {Mixed} b
 * @return {Boolean} result
 */

/*!
 * chai
 * Copyright(c) 2011-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai version
 */

/*!
 * Assertion Error
 */

/*!
 * Utils for plugins (not exported)
 */

/*!
 * Configuration
 */

/*!
 * Primary `Assertion` prototype
 */

/*!
 * Core Assertions
 */

/*!
 * Expect interface
 */

/*!
 * Should interface
 */

/*!
 * Assert interface
 */

/*!
 * chai
 * http://chaijs.com
 * Copyright(c) 2011-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
   * Module dependencies.
   */

/*!
   * Module export.
   */

/*!
   * Assertion Constructor
   *
   * Creates object for chaining.
   *
   * @api private
   */

/*!
   * ### .assert(expression, message, negateMessage, expected, actual)
   *
   * Executes an expression and check expectations. Throws AssertionError for reporting if test doesn't pass.
   *
   * @name assert
   * @param {Philosophical} expression to be tested
   * @param {String or Function} message or function that returns message to display if fails
   * @param {String or Function} negatedMessage or function that returns negatedMessage to display if negated expression fails
   * @param {Mixed} expected value (remember to check for negation)
   * @param {Mixed} actual (optional) will default to `this.obj`
   * @api private
   */

/*!
   * ### ._obj
   *
   * Quick reference to stored `actual` value for plugin developers.
   *
   * @api private
   */

/*!
   * Chai dependencies.
   */

/*!
   * Undocumented / untested
   */

/*!
   * Aliases.
   */

/*!
 * Chai - addChainingMethod utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Module variables
 */

/*!
 * Chai - addMethod utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - addProperty utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - flag utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - getActual utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - getEnumerableProperties utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - message composition utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Module dependancies
 */

/*!
 * Chai - getName utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - getPathValue utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * @see https://github.com/logicalparadox/filtr
 * MIT Licensed
 */

/*!
 * ## parsePath(path)
 *
 * Helper function used to parse string object
 * paths. Use in conjunction with `_getPathValue`.
 *
 *      var parsed = parsePath('myobject.property.subprop');
 *
 * ### Paths:
 *
 * * Can be as near infinitely deep and nested
 * * Arrays are also valid using the formal `myobject.document[3].property`.
 *
 * @param {String} path
 * @returns {Object} parsed
 * @api private
 */

/*!
 * ## _getPathValue(parsed, obj)
 *
 * Helper companion function for `.parsePath` that returns
 * the value located at the parsed address.
 *
 *      var value = getPathValue(parsed, obj);
 *
 * @param {Object} parsed definition from `parsePath`.
 * @param {Object} object to search against
 * @returns {Object|Undefined} value
 * @api private
 */

/*!
 * Chai - getProperties utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * chai
 * Copyright(c) 2011 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Main exports
 */

/*!
 * test utility
 */

/*!
 * type utility
 */

/*!
 * message utility
 */

/*!
 * actual utility
 */

/*!
 * Inspect util
 */

/*!
 * Object Display util
 */

/*!
 * Flag utility
 */

/*!
 * Flag transferring utility
 */

/*!
 * Deep equal utility
 */

/*!
 * Deep path value
 */

/*!
 * Function name
 */

/*!
 * add Property
 */

/*!
 * add Method
 */

/*!
 * overwrite Property
 */

/*!
 * overwrite Method
 */

/*!
 * Add a chainable method
 */

/*!
 * Overwrite chainable method
 */

/*!
 * Chai - overwriteMethod utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - overwriteProperty utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - overwriteChainableMethod utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - test utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - transferFlags utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

/*!
 * Chai - type utility
 * Copyright(c) 2012-2014 Jake Luer <jake@alogicalparadox.com>
 * MIT Licensed
 */

(function(){function require(e,t,n){var r=require.resolve(e);if(null==r){n=n||e,t=t||"root";var i=new Error('Failed to require "'+n+'" from "'+t+'"');throw i.path=n,i.parent=t,i.require=!0,i}var s=require.modules[r];if(!s._resolving&&!s.exports){var o={};o.exports={},o.client=o.component=!0,s._resolving=!0,s.call(this,o.exports,require.relative(r),o),delete s._resolving,s.exports=o.exports}return s.exports}require.modules={},require.aliases={},require.resolve=function(e){e.charAt(0)==="/"&&(e=e.slice(1));var t=[e,e+".js",e+".json",e+"/index.js",e+"/index.json"];for(var n=0;n<t.length;n++){var e=t[n];if(require.modules.hasOwnProperty(e))return e;if(require.aliases.hasOwnProperty(e))return require.aliases[e]}},require.normalize=function(e,t){var n=[];if("."!=t.charAt(0))return t;e=e.split("/"),t=t.split("/");for(var r=0;r<t.length;++r)".."==t[r]?e.pop():"."!=t[r]&&""!=t[r]&&n.push(t[r]);return e.concat(n).join("/")},require.register=function(e,t){require.modules[e]=t},require.alias=function(e,t){if(!require.modules.hasOwnProperty(e))throw new Error('Failed to alias "'+e+'", it does not exist');require.aliases[t]=e},require.relative=function(e){function n(e,t){var n=e.length;while(n--)if(e[n]===t)return n;return-1}function r(t){var n=r.resolve(t);return require(n,e,t)}var t=require.normalize(e,"..");return r.resolve=function(r){var i=r.charAt(0);if("/"==i)return r.slice(1);if("."==i)return require.normalize(t,r);var s=e.split("/"),o=n(s,"deps")+1;return o||(o=0),r=s.slice(0,o+1).join("/")+"/deps/"+r,r},r.exists=function(e){return require.modules.hasOwnProperty(r.resolve(e))},r},require.register("chaijs-assertion-error/index.js",function(e,t,n){function r(){function t(t,n){Object.keys(n).forEach(function(r){~e.indexOf(r)||(t[r]=n[r])})}var e=[].slice.call(arguments);return function(){var n=[].slice.call(arguments),r=0,i={};for(;r<n.length;r++)t(i,n[r]);return i}}function i(e,t,n){var i=r("name","message","stack","constructor","toJSON"),s=i(t||{});this.message=e||"Unspecified AssertionError",this.showDiff=!1;for(var o in s)this[o]=s[o];n=n||arguments.callee,n&&Error.captureStackTrace&&Error.captureStackTrace(this,n)}n.exports=i,i.prototype=Object.create(Error.prototype),i.prototype.name="AssertionError",i.prototype.constructor=i,i.prototype.toJSON=function(e){var t=r("constructor","toJSON","stack"),n=t({name:this.name},this);return!1!==e&&this.stack&&(n.stack=this.stack),n}}),require.register("chaijs-type-detect/lib/type.js",function(e,t,n){function i(e){var t=Object.prototype.toString.call(e);return r[t]?r[t]:e===null?"null":e===undefined?"undefined":e===Object(e)?"object":typeof e}function s(){this.tests={}}var e=n.exports=i,r={"[object Array]":"array","[object RegExp]":"regexp","[object Function]":"function","[object Arguments]":"arguments","[object Date]":"date"};e.Library=s,s.prototype.of=i,s.prototype.define=function(e,t){return arguments.length===1?this.tests[e]:(this.tests[e]=t,this)},s.prototype.test=function(e,t){if(t===i(e))return!0;var n=this.tests[t];if(n&&"regexp"===i(n))return n.test(e);if(n&&"function"===i(n))return n(e);throw new ReferenceError('Type test "'+t+'" not defined or invalid.')}}),require.register("chaijs-deep-eql/lib/eql.js",function(e,t,n){function o(e,t,n){return u(e,t)?!0:"date"===r(e)?f(e,t):"regexp"===r(e)?l(e,t):i.isBuffer(e)?d(e,t):"arguments"===r(e)?c(e,t,n):a(e,t)?"object"!==r(e)&&"object"!==r(t)&&"array"!==r(e)&&"array"!==r(t)?u(e,t):m(e,t,n):!1}function u(e,t){return e===t?e!==0||1/e===1/t:e!==e&&t!==t}function a(e,t){return r(e)===r(t)}function f(e,t){return"date"!==r(t)?!1:u(e.getTime(),t.getTime())}function l(e,t){return"regexp"!==r(t)?!1:u(e.toString(),t.toString())}function c(e,t,n){return"arguments"!==r(t)?!1:(e=[].slice.call(e),t=[].slice.call(t),o(e,t,n))}function h(e){var t=[];for(var n in e)t.push(n);return t}function p(e,t){if(e.length!==t.length)return!1;var n=0,r=!0;for(;n<e.length;n++)if(e[n]!==t[n]){r=!1;break}return r}function d(e,t){return i.isBuffer(t)?p(e,t):!1}function v(e){return e!==null&&e!==undefined}function m(e,t,n){if(!v(e)||!v(t))return!1;if(e.prototype!==t.prototype)return!1;var r;if(n){for(r=0;r<n.length;r++)if(n[r][0]===e&&n[r][1]===t||n[r][0]===t&&n[r][1]===e)return!0}else n=[];try{var i=h(e),s=h(t)}catch(u){return!1}i.sort(),s.sort();if(!p(i,s))return!1;n.push([e,t]);var a;for(r=i.length-1;r>=0;r--){a=i[r];if(!o(e[a],t[a],n))return!1}return!0}var r=t("type-detect"),i;try{i=t("buffer").Buffer}catch(s){i={},i.isBuffer=function(){return!1}}n.exports=o}),require.register("chai/index.js",function(e,t,n){n.exports=t("./lib/chai")}),require.register("chai/lib/chai.js",function(e,t,n){var r=[],e=n.exports={};e.version="1.9.2",e.AssertionError=t("assertion-error");var i=t("./chai/utils");e.use=function(e){return~r.indexOf(e)||(e(this,i),r.push(e)),this};var s=t("./chai/config");e.config=s;var o=t("./chai/assertion");e.use(o);var u=t("./chai/core/assertions");e.use(u);var a=t("./chai/interface/expect");e.use(a);var f=t("./chai/interface/should");e.use(f);var l=t("./chai/interface/assert");e.use(l)}),require.register("chai/lib/chai/assertion.js",function(e,t,n){var r=t("./config");n.exports=function(e,t){function s(e,t,n){i(this,"ssfi",n||arguments.callee),i(this,"object",e),i(this,"message",t)}var n=e.AssertionError,i=t.flag;e.Assertion=s,Object.defineProperty(s,"includeStack",{get:function(){return console.warn("Assertion.includeStack is deprecated, use chai.config.includeStack instead."),r.includeStack},set:function(e){console.warn("Assertion.includeStack is deprecated, use chai.config.includeStack instead."),r.includeStack=e}}),Object.defineProperty(s,"showDiff",{get:function(){return console.warn("Assertion.showDiff is deprecated, use chai.config.showDiff instead."),r.showDiff},set:function(e){console.warn("Assertion.showDiff is deprecated, use chai.config.showDiff instead."),r.showDiff=e}}),s.addProperty=function(e,n){t.addProperty(this.prototype,e,n)},s.addMethod=function(e,n){t.addMethod(this.prototype,e,n)},s.addChainableMethod=function(e,n,r){t.addChainableMethod(this.prototype,e,n,r)},s.overwriteProperty=function(e,n){t.overwriteProperty(this.prototype,e,n)},s.overwriteMethod=function(e,n){t.overwriteMethod(this.prototype,e,n)},s.overwriteChainableMethod=function(e,n,r){t.overwriteChainableMethod(this.prototype,e,n,r)},s.prototype.assert=function(e,s,o,u,a,f){var l=t.test(this,arguments);!0!==f&&(f=!1),!0!==r.showDiff&&(f=!1);if(!l){var s=t.getMessage(this,arguments),c=t.getActual(this,arguments);throw new n(s,{actual:c,expected:u,showDiff:f},r.includeStack?this.assert:i(this,"ssfi"))}},Object.defineProperty(s.prototype,"_obj",{get:function(){return i(this,"object")},set:function(e){i(this,"object",e)}})}}),require.register("chai/lib/chai/config.js",function(e,t,n){n.exports={includeStack:!1,showDiff:!0,truncateThreshold:40}}),require.register("chai/lib/chai/core/assertions.js",function(e,t,n){n.exports=function(e,t){function s(e,n){n&&i(this,"message",n),e=e.toLowerCase();var r=i(this,"object"),s=~["a","e","i","o","u"].indexOf(e.charAt(0))?"an ":"a ";this.assert(e===t.type(r),"expected #{this} to be "+s+e,"expected #{this} not to be "+s+e)}function o(){i(this,"contains",!0)}function u(e,r){r&&i(this,"message",r);var s=i(this,"object"),o=!1;if(t.type(s)==="array"&&t.type(e)==="object"){for(var u in s)if(t.eql(s[u],e)){o=!0;break}}else if(t.type(e)==="object"){if(!i(this,"negate")){for(var a in e)(new n(s)).property(a,e[a]);return}var f={};for(var a in e)f[a]=s[a];o=t.eql(f,e)}else o=s&&~s.indexOf(e);this.assert(o,"expected #{this} to include "+t.inspect(e),"expected #{this} to not include "+t.inspect(e))}function a(){var e=i(this,"object"),t=Object.prototype.toString.call(e);this.assert("[object Arguments]"===t,"expected #{this} to be arguments but got "+t,"expected #{this} to not be arguments")}function f(e,t){t&&i(this,"message",t);var n=i(this,"object");if(i(this,"deep"))return this.eql(e);this.assert(e===n,"expected #{this} to equal #{exp}","expected #{this} to not equal #{exp}",e,this._obj,!0)}function l(e,n){n&&i(this,"message",n),this.assert(t.eql(e,i(this,"object")),"expected #{this} to deeply equal #{exp}","expected #{this} to not deeply equal #{exp}",e,this._obj,!0)}function c(e,t){t&&i(this,"message",t);var r=i(this,"object");if(i(this,"doLength")){(new n(r,t)).to.have.property("length");var s=r.length;this.assert(s>e,"expected #{this} to have a length above #{exp} but got #{act}","expected #{this} to not have a length above #{exp}",e,s)}else this.assert(r>e,"expected #{this} to be above "+e,"expected #{this} to be at most "+e)}function h(e,t){t&&i(this,"message",t);var r=i(this,"object");if(i(this,"doLength")){(new n(r,t)).to.have.property("length");var s=r.length;this.assert(s>=e,"expected #{this} to have a length at least #{exp} but got #{act}","expected #{this} to have a length below #{exp}",e,s)}else this.assert(r>=e,"expected #{this} to be at least "+e,"expected #{this} to be below "+e)}function p(e,t){t&&i(this,"message",t);var r=i(this,"object");if(i(this,"doLength")){(new n(r,t)).to.have.property("length");var s=r.length;this.assert(s<e,"expected #{this} to have a length below #{exp} but got #{act}","expected #{this} to not have a length below #{exp}",e,s)}else this.assert(r<e,"expected #{this} to be below "+e,"expected #{this} to be at least "+e)}function d(e,t){t&&i(this,"message",t);var r=i(this,"object");if(i(this,"doLength")){(new n(r,t)).to.have.property("length");var s=r.length;this.assert(s<=e,"expected #{this} to have a length at most #{exp} but got #{act}","expected #{this} to have a length above #{exp}",e,s)}else this.assert(r<=e,"expected #{this} to be at most "+e,"expected #{this} to be above "+e)}function v(e,n){n&&i(this,"message",n);var r=t.getName(e);this.assert(i(this,"object")instanceof e,"expected #{this} to be an instance of "+r,"expected #{this} to not be an instance of "+r)}function m(e,n){n&&i(this,"message",n);var r=i(this,"object");this.assert(r.hasOwnProperty(e),"expected #{this} to have own property "+t.inspect(e),"expected #{this} to not have own property "+t.inspect(e))}function g(){i(this,"doLength",!0)}function y(e,t){t&&i(this,"message",t);var r=i(this,"object");(new n(r,t)).to.have.property("length");var s=r.length;this.assert(s==e,"expected #{this} to have a length of #{exp} but got #{act}","expected #{this} to not have a length of #{act}",e,s)}function b(e){var n=i(this,"object"),r,s=!0;e=e instanceof Array?e:Array.prototype.slice.call(arguments);if(!e.length)throw new Error("keys required");var o=Object.keys(n),u=e,a=e.length;s=e.every(function(e){return~o.indexOf(e)}),!i(this,"negate")&&!i(this,"contains")&&(s=s&&e.length==o.length);if(a>1){e=e.map(function(e){return t.inspect(e)});var f=e.pop();r=e.join(", ")+", and "+f}else r=t.inspect(e[0]);r=(a>1?"keys ":"key ")+r,r=(i(this,"contains")?"contain ":"have ")+r,this.assert(s,"expected #{this} to "+r,"expected #{this} to not "+r,u.sort(),o.sort(),!0)}function w(e,r,s){s&&i(this,"message",s);var o=i(this,"object");(new n(o,s)).is.a("function");var u=!1,a=null,f=null,l=null;arguments.length===0?(r=null,e=null):e&&(e instanceof RegExp||"string"==typeof e)?(r=e,e=null):e&&e instanceof Error?(a=e,e=null,r=null):typeof e=="function"?(f=e.prototype.name||e.name,f==="Error"&&e!==Error&&(f=(new e).name)):e=null;try{o()}catch(c){if(a)return this.assert(c===a,"expected #{this} to throw #{exp} but #{act} was thrown","expected #{this} to not throw #{exp}",a instanceof Error?a.toString():a,c instanceof Error?c.toString():c),i(this,"object",c),this;if(e){this.assert(c instanceof e,"expected #{this} to throw #{exp} but #{act} was thrown","expected #{this} to not throw #{exp} but #{act} was thrown",f,c instanceof Error?c.toString():c);if(!r)return i(this,"object",c),this}var h="object"===t.type(c)&&"message"in c?c.message:""+c;if(h!=null&&r&&r instanceof RegExp)return this.assert(r.exec(h),"expected #{this} to throw error matching #{exp} but got #{act}","expected #{this} to throw error not matching #{exp}",r,h),i(this,"object",c),this;if(h!=null&&r&&"string"==typeof r)return this.assert(~h.indexOf(r),"expected #{this} to throw error including #{exp} but got #{act}","expected #{this} to throw error not including #{act}",r,h),i(this,"object",c),this;u=!0,l=c}var p="",d=f!==null?f:a?"#{exp}":"an error";u&&(p=" but #{act} was thrown"),this.assert(u===!0,"expected #{this} to throw "+d+p,"expected #{this} to not throw "+d+p,a instanceof Error?a.toString():a,l instanceof Error?l.toString():l),i(this,"object",l)}function E(e,t,n){return e.every(function(e){return n?t.some(function(t){return n(e,t)}):t.indexOf(e)!==-1})}var n=e.Assertion,r=Object.prototype.toString,i=t.flag;["to","be","been","is","and","has","have","with","that","at","of","same"].forEach(function(e){n.addProperty(e,function(){return this})}),n.addProperty("not",function(){i(this,"negate",!0)}),n.addProperty("deep",function(){i(this,"deep",!0)}),n.addChainableMethod("an",s),n.addChainableMethod("a",s),n.addChainableMethod("include",u,o),n.addChainableMethod("contain",u,o),n.addProperty("ok",function(){this.assert(i(this,"object"),"expected #{this} to be truthy","expected #{this} to be falsy")}),n.addProperty("true",function(){this.assert(!0===i(this,"object"),"expected #{this} to be true","expected #{this} to be false",this.negate?!1:!0)}),n.addProperty("false",function(){this.assert(!1===i(this,"object"),"expected #{this} to be false","expected #{this} to be true",this.negate?!0:!1)}),n.addProperty("null",function(){this.assert(null===i(this,"object"),"expected #{this} to be null","expected #{this} not to be null")}),n.addProperty("undefined",function(){this.assert(undefined===i(this,"object"),"expected #{this} to be undefined","expected #{this} not to be undefined")}),n.addProperty("exist",function(){this.assert(null!=i(this,"object"),"expected #{this} to exist","expected #{this} to not exist")}),n.addProperty("empty",function(){var e=i(this,"object"),t=e;Array.isArray(e)||"string"==typeof object?t=e.length:typeof e=="object"&&(t=Object.keys(e).length),this.assert(!t,"expected #{this} to be empty","expected #{this} not to be empty")}),n.addProperty("arguments",a),n.addProperty("Arguments",a),n.addMethod("equal",f),n.addMethod("equals",f),n.addMethod("eq",f),n.addMethod("eql",l),n.addMethod("eqls",l),n.addMethod("above",c),n.addMethod("gt",c),n.addMethod("greaterThan",c),n.addMethod("least",h),n.addMethod("gte",h),n.addMethod("below",p),n.addMethod("lt",p),n.addMethod("lessThan",p),n.addMethod("most",d),n.addMethod("lte",d),n.addMethod("within",function(e,t,r){r&&i(this,"message",r);var s=i(this,"object"),o=e+".."+t;if(i(this,"doLength")){(new n(s,r)).to.have.property("length");var u=s.length;this.assert(u>=e&&u<=t,"expected #{this} to have a length within "+o,"expected #{this} to not have a length within "+o)}else this.assert(s>=e&&s<=t,"expected #{this} to be within "+o,"expected #{this} to not be within "+o)}),n.addMethod("instanceof",v),n.addMethod("instanceOf",v),n.addMethod("property",function(e,n,r){r&&i(this,"message",r);var s=i(this,"deep")?"deep property ":"property ",o=i(this,"negate"),u=i(this,"object"),a=i(this,"deep")?t.getPathValue(e,u):u[e];if(o&&undefined!==n){if(undefined===a)throw r=r!=null?r+": ":"",new Error(r+t.inspect(u)+" has no "+s+t.inspect(e))}else this.assert(undefined!==a,"expected #{this} to have a "+s+t.inspect(e),"expected #{this} to not have "+s+t.inspect(e));undefined!==n&&this.assert(n===a,"expected #{this} to have a "+s+t.inspect(e)+" of #{exp}, but got #{act}","expected #{this} to not have a "+s+t.inspect(e)+" of #{act}",n,a),i(this,"object",a)}),n.addMethod("ownProperty",m),n.addMethod("haveOwnProperty",m),n.addChainableMethod("length",y,g),n.addMethod("lengthOf",y),n.addMethod("match",function(e,t){t&&i(this,"message",t);var n=i(this,"object");this.assert(e.exec(n),"expected #{this} to match "+e,"expected #{this} not to match "+e)}),n.addMethod("string",function(e,r){r&&i(this,"message",r);var s=i(this,"object");(new n(s,r)).is.a("string"),this.assert(~s.indexOf(e),"expected #{this} to contain "+t.inspect(e),"expected #{this} to not contain "+t.inspect(e))}),n.addMethod("keys",b),n.addMethod("key",b),n.addMethod("throw",w),n.addMethod("throws",w),n.addMethod("Throw",w),n.addMethod("respondTo",function(e,n){n&&i(this,"message",n);var r=i(this,"object"),s=i(this,"itself"),o="function"===t.type(r)&&!s?r.prototype[e]:r[e];this.assert("function"==typeof o,"expected #{this} to respond to "+t.inspect(e),"expected #{this} to not respond to "+t.inspect(e))}),n.addProperty("itself",function(){i(this,"itself",!0)}),n.addMethod("satisfy",function(e,n){n&&i(this,"message",n);var r=i(this,"object"),s=e(r);this.assert(s,"expected #{this} to satisfy "+t.objDisplay(e),"expected #{this} to not satisfy"+t.objDisplay(e),this.negate?!1:!0,s)}),n.addMethod("closeTo",function(e,r,s){s&&i(this,"message",s);var o=i(this,"object");(new n(o,s)).is.a("number");if(t.type(e)!=="number"||t.type(r)!=="number")throw new Error("the arguments to closeTo must be numbers");this.assert(Math.abs(o-e)<=r,"expected #{this} to be close to "+e+" +/- "+r,"expected #{this} not to be close to "+e+" +/- "+r)}),n.addMethod("members",function(e,r){r&&i(this,"message",r);var s=i(this,"object");(new n(s)).to.be.an("array"),(new n(e)).to.be.an("array");var o=i(this,"deep")?t.eql:undefined;if(i(this,"contains"))return this.assert(E(e,s,o),"expected #{this} to be a superset of #{act}","expected #{this} to not be a superset of #{act}",s,e);this.assert(E(s,e,o)&&E(e,s,o),"expected #{this} to have the same members as #{act}","expected #{this} to not have the same members as #{act}",s,e)})}}),require.register("chai/lib/chai/interface/assert.js",function(exports,require,module){module.exports=function(chai,util){var Assertion=chai.Assertion,flag=util.flag,assert=chai.assert=function(e,t){var n=new Assertion(null,null,chai.assert);n.assert(e,t,"[ negation message unavailable ]")};assert.fail=function(e,t,n,r){throw n=n||"assert.fail()",new chai.AssertionError(n,{actual:e,expected:t,operator:r},assert.fail)},assert.ok=function(e,t){(new Assertion(e,t)).is.ok},assert.notOk=function(e,t){(new Assertion(e,t)).is.not.ok},assert.equal=function(e,t,n){var r=new Assertion(e,n,assert.equal);r.assert(t==flag(r,"object"),"expected #{this} to equal #{exp}","expected #{this} to not equal #{act}",t,e)},assert.notEqual=function(e,t,n){var r=new Assertion(e,n,assert.notEqual);r.assert(t!=flag(r,"object"),"expected #{this} to not equal #{exp}","expected #{this} to equal #{act}",t,e)},assert.strictEqual=function(e,t,n){(new Assertion(e,n)).to.equal(t)},assert.notStrictEqual=function(e,t,n){(new Assertion(e,n)).to.not.equal(t)},assert.deepEqual=function(e,t,n){(new Assertion(e,n)).to.eql(t)},assert.notDeepEqual=function(e,t,n){(new Assertion(e,n)).to.not.eql(t)},assert.isTrue=function(e,t){(new Assertion(e,t)).is["true"]},assert.isFalse=function(e,t){(new Assertion(e,t)).is["false"]},assert.isNull=function(e,t){(new Assertion(e,t)).to.equal(null)},assert.isNotNull=function(e,t){(new Assertion(e,t)).to.not.equal(null)},assert.isUndefined=function(e,t){(new Assertion(e,t)).to.equal(undefined)},assert.isDefined=function(e,t){(new Assertion(e,t)).to.not.equal(undefined)},assert.isFunction=function(e,t){(new Assertion(e,t)).to.be.a("function")},assert.isNotFunction=function(e,t){(new Assertion(e,t)).to.not.be.a("function")},assert.isObject=function(e,t){(new Assertion(e,t)).to.be.a("object")},assert.isNotObject=function(e,t){(new Assertion(e,t)).to.not.be.a("object")},assert.isArray=function(e,t){(new Assertion(e,t)).to.be.an("array")},assert.isNotArray=function(e,t){(new Assertion(e,t)).to.not.be.an("array")},assert.isString=function(e,t){(new Assertion(e,t)).to.be.a("string")},assert.isNotString=function(e,t){(new Assertion(e,t)).to.not.be.a("string")},assert.isNumber=function(e,t){(new Assertion(e,t)).to.be.a("number")},assert.isNotNumber=function(e,t){(new Assertion(e,t)).to.not.be.a("number")},assert.isBoolean=function(e,t){(new Assertion(e,t)).to.be.a("boolean")},assert.isNotBoolean=function(e,t){(new Assertion(e,t)).to.not.be.a("boolean")},assert.typeOf=function(e,t,n){(new Assertion(e,n)).to.be.a(t)},assert.notTypeOf=function(e,t,n){(new Assertion(e,n)).to.not.be.a(t)},assert.instanceOf=function(e,t,n){(new Assertion(e,n)).to.be.instanceOf(t)},assert.notInstanceOf=function(e,t,n){(new Assertion(e,n)).to.not.be.instanceOf(t)},assert.include=function(e,t,n){(new Assertion(e,n,assert.include)).include(t)},assert.notInclude=function(e,t,n){(new Assertion(e,n,assert.notInclude)).not.include(t)},assert.match=function(e,t,n){(new Assertion(e,n)).to.match(t)},assert.notMatch=function(e,t,n){(new Assertion(e,n)).to.not.match(t)},assert.property=function(e,t,n){(new Assertion(e,n)).to.have.property(t)},assert.notProperty=function(e,t,n){(new Assertion(e,n)).to.not.have.property(t)},assert.deepProperty=function(e,t,n){(new Assertion(e,n)).to.have.deep.property(t)},assert.notDeepProperty=function(e,t,n){(new Assertion(e,n)).to.not.have.deep.property(t)},assert.propertyVal=function(e,t,n,r){(new Assertion(e,r)).to.have.property(t,n)},assert.propertyNotVal=function(e,t,n,r){(new Assertion(e,r)).to.not.have.property(t,n)},assert.deepPropertyVal=function(e,t,n,r){(new Assertion(e,r)).to.have.deep.property(t,n)},assert.deepPropertyNotVal=function(e,t,n,r){(new Assertion(e,r)).to.not.have.deep.property(t,n)},assert.lengthOf=function(e,t,n){(new Assertion(e,n)).to.have.length(t)},assert.Throw=function(e,t,n,r){if("string"==typeof t||t instanceof RegExp)n=t,t=null;var i=(new Assertion(e,r)).to.Throw(t,n);return flag(i,"object")},assert.doesNotThrow=function(e,t,n){"string"==typeof t&&(n=t,t=null),(new Assertion(e,n)).to.not.Throw(t)},assert.operator=function(val,operator,val2,msg){if(!~["==","===",">",">=","<","<=","!=","!=="].indexOf(operator))throw new Error('Invalid operator "'+operator+'"');var test=new Assertion(eval(val+operator+val2),msg);test.assert(!0===flag(test,"object"),"expected "+util.inspect(val)+" to be "+operator+" "+util.inspect(val2),"expected "+util.inspect(val)+" to not be "+operator+" "+util.inspect(val2))},assert.closeTo=function(e,t,n,r){(new Assertion(e,r)).to.be.closeTo(t,n)},assert.sameMembers=function(e,t,n){(new Assertion(e,n)).to.have.same.members(t)},assert.includeMembers=function(e,t,n){(new Assertion(e,n)).to.include.members(t)},assert.ifError=function(e,t){(new Assertion(e,t)).to.not.be.ok},function alias(e,t){return assert[t]=assert[e],alias}("Throw","throw")("Throw","throws")}}),require.register("chai/lib/chai/interface/expect.js",function(e,t,n){n.exports=function(e,t){e.expect=function(t,n){return new e.Assertion(t,n)}}}),require.register("chai/lib/chai/interface/should.js",function(e,t,n){n.exports=function(e,t){function r(){function e(){return this instanceof String||this instanceof Number?new n(this.constructor(this),null,e):this instanceof Boolean?new n(this==1,null,e):new n(this,null,e)}function t(e){Object.defineProperty(this,"should",{value:e,enumerable:!0,configurable:!0,writable:!0})}Object.defineProperty(Object.prototype,"should",{set:t,get:e,configurable:!0});var r={};return r.equal=function(e,t,r){(new n(e,r)).to.equal(t)},r.Throw=function(e,t,r,i){(new n(e,i)).to.Throw(t,r)},r.exist=function(e,t){(new n(e,t)).to.exist},r.not={},r.not.equal=function(e,t,r){(new n(e,r)).to.not.equal(t)},r.not.Throw=function(e,t,r,i){(new n(e,i)).to.not.Throw(t,r)},r.not.exist=function(e,t){(new n(e,t)).to.not.exist},r["throw"]=r.Throw,r.not["throw"]=r.not.Throw,r}var n=e.Assertion;e.should=r,e.Should=r}}),require.register("chai/lib/chai/utils/addChainableMethod.js",function(e,t,n){var r=t("./transferFlags"),i=t("./flag"),s=t("../config"),o="__proto__"in Object,u=/^(?:length|name|arguments|caller)$/,a=Function.prototype.call,f=Function.prototype.apply;n.exports=function(e,t,n,l){typeof l!="function"&&(l=function(){});var c={method:n,chainingBehavior:l};e.__methods||(e.__methods={}),e.__methods[t]=c,Object.defineProperty(e,t,{get:function(){c.chainingBehavior.call(this);var t=function h(){var e=i(this,"ssfi");e&&s.includeStack===!1&&i(this,"ssfi",h);var t=c.method.apply(this,arguments);return t===undefined?this:t};if(o){var n=t.__proto__=Object.create(this);n.call=a,n.apply=f}else{var l=Object.getOwnPropertyNames(e);l.forEach(function(n){if(!u.test(n)){var r=Object.getOwnPropertyDescriptor(e,n);Object.defineProperty(t,n,r)}})}return r(this,t),t},configurable:!0})}}),require.register("chai/lib/chai/utils/addMethod.js",function(e,t,n){var r=t("../config"),i=t("./flag");n.exports=function(e,t,n){e[t]=function(){var s=i(this,"ssfi");s&&r.includeStack===!1&&i(this,"ssfi",e[t]);var o=n.apply(this,arguments);return o===undefined?this:o}}}),require.register("chai/lib/chai/utils/addProperty.js",function(e,t,n){n.exports=function(e,t,n){Object.defineProperty(e,t,{get:function(){var e=n.call(this);return e===undefined?this:e},configurable:!0})}}),require.register("chai/lib/chai/utils/flag.js",function(e,t,n){n.exports=function(e,t,n){var r=e.__flags||(e.__flags=Object.create(null));if(arguments.length!==3)return r[t];r[t]=n}}),require.register("chai/lib/chai/utils/getActual.js",function(e,t,n){n.exports=function(e,t){return t.length>4?t[4]:e._obj}}),require.register("chai/lib/chai/utils/getEnumerableProperties.js",function(e,t,n){n.exports=function(t){var n=[];for(var r in t)n.push(r);return n}}),require.register("chai/lib/chai/utils/getMessage.js",function(e,t,n){var r=t("./flag"),i=t("./getActual"),s=t("./inspect"),o=t("./objDisplay");n.exports=function(e,t){var n=r(e,"negate"),s=r(e,"object"),u=t[3],a=i(e,t),f=n?t[2]:t[1],l=r(e,"message");return typeof f=="function"&&(f=f()),f=f||"",f=f.replace(/#{this}/g,o(s)).replace(/#{act}/g,o(a)).replace(/#{exp}/g,o(u)),l?l+": "+f:f}}),require.register("chai/lib/chai/utils/getName.js",function(e,t,n){n.exports=function(e){if(e.name)return e.name;var t=/^\s?function ([^(]*)\(/.exec(e);return t&&t[1]?t[1]:""}}),require.register("chai/lib/chai/utils/getPathValue.js",function(e,t,n){function i(e){var t=e.replace(/\[/g,".["),n=t.match(/(\\\.|[^.]+?)+/g);return n.map(function(e){var t=/\[(\d+)\]$/,n=t.exec(e);return n?{i:parseFloat(n[1])}:{p:e}})}function s(e,t){var n=t,r;for(var i=0,s=e.length;i<s;i++){var o=e[i];n?("undefined"!=typeof o.p?n=n[o.p]:"undefined"!=typeof o.i&&(n=n[o.i]),i==s-1&&(r=n)):r=undefined}return r}var r=n.exports=function(e,t){var n=i(e);return s(n,t)}}),require.register("chai/lib/chai/utils/getProperties.js",function(e,t,n){n.exports=function(t){function r(e){n.indexOf(e)===-1&&n.push(e)}var n=Object.getOwnPropertyNames(subject),i=Object.getPrototypeOf(subject);while(i!==null)Object.getOwnPropertyNames(i).forEach(r),i=Object.getPrototypeOf(i);return n}}),require.register("chai/lib/chai/utils/index.js",function(e,t,n){var e=n.exports={};e.test=t("./test"),e.type=t("./type"),e.getMessage=t("./getMessage"),e.getActual=t("./getActual"),e.inspect=t("./inspect"),e.objDisplay=t("./objDisplay"),e.flag=t("./flag"),e.transferFlags=t("./transferFlags"),e.eql=t("deep-eql"),e.getPathValue=t("./getPathValue"),e.getName=t("./getName"),e.addProperty=t("./addProperty"),e.addMethod=t("./addMethod"),e.overwriteProperty=t("./overwriteProperty"),e.overwriteMethod=t("./overwriteMethod"),e.addChainableMethod=t("./addChainableMethod"),e.overwriteChainableMethod=t("./overwriteChainableMethod")}),require.register("chai/lib/chai/utils/inspect.js",function(e,t,n){function o(e,t,n,r){var i={showHidden:t,seen:[],stylize:function(e){return e}};return a(i,e,typeof n=="undefined"?2:n)}function a(t,n,o){if(n&&typeof n.inspect=="function"&&n.inspect!==e.inspect&&(!n.constructor||n.constructor.prototype!==n)){var y=n.inspect(o);return typeof y!="string"&&(y=a(t,y,o)),y}var b=f(t,n);if(b)return b;if(u(n)){if("outerHTML"in n)return n.outerHTML;try{if(document.xmlVersion){var w=new XMLSerializer;return w.serializeToString(n)}var E="http://www.w3.org/1999/xhtml",S=document.createElementNS(E,"_");return S.appendChild(n.cloneNode(!1)),html=S.innerHTML.replace("><",">"+n.innerHTML+"<"),S.innerHTML="",html}catch(x){}}var T=s(n),N=t.showHidden?i(n):T;if(N.length===0||g(n)&&(N.length===1&&N[0]==="stack"||N.length===2&&N[0]==="description"&&N[1]==="stack")){if(typeof n=="function"){var C=r(n),k=C?": "+C:"";return t.stylize("[Function"+k+"]","special")}if(v(n))return t.stylize(RegExp.prototype.toString.call(n),"regexp");if(m(n))return t.stylize(Date.prototype.toUTCString.call(n),"date");if(g(n))return l(n)}var L="",A=!1,O=["{","}"];d(n)&&(A=!0,O=["[","]"]);if(typeof n=="function"){var C=r(n),k=C?": "+C:"";L=" [Function"+k+"]"}v(n)&&(L=" "+RegExp.prototype.toString.call(n)),m(n)&&(L=" "+Date.prototype.toUTCString.call(n));if(g(n))return l(n);if(N.length!==0||!!A&&n.length!=0){if(o<0)return v(n)?t.stylize(RegExp.prototype.toString.call(n),"regexp"):t.stylize("[Object]","special");t.seen.push(n);var M;return A?M=c(t,n,o,T,N):M=N.map(function(e){return h(t,n,o,T,e,A)}),t.seen.pop(),p(M,L,O)}return O[0]+L+O[1]}function f(e,t){switch(typeof t){case"undefined":return e.stylize("undefined","undefined");case"string":var n="'"+JSON.stringify(t).replace(/^"|"$/g,"").replace(/'/g,"\\'").replace(/\\"/g,'"')+"'";return e.stylize(n,"string");case"number":return e.stylize(""+t,"number");case"boolean":return e.stylize(""+t,"boolean")}if(t===null)return e.stylize("null","null")}function l(e){return"["+Error.prototype.toString.call(e)+"]"}function c(e,t,n,r,i){var s=[];for(var o=0,u=t.length;o<u;++o)Object.prototype.hasOwnProperty.call(t,String(o))?s.push(h(e,t,n,r,String(o),!0)):s.push("");return i.forEach(function(i){i.match(/^\d+$/)||s.push(h(e,t,n,r,i,!0))}),s}function h(e,t,n,r,i,s){var o,u;t.__lookupGetter__&&(t.__lookupGetter__(i)?t.__lookupSetter__(i)?u=e.stylize("[Getter/Setter]","special"):u=e.stylize("[Getter]","special"):t.__lookupSetter__(i)&&(u=e.stylize("[Setter]","special"))),r.indexOf(i)<0&&(o="["+i+"]"),u||(e.seen.indexOf(t[i])<0?(n===null?u=a(e,t[i],null):u=a(e,t[i],n-1),u.indexOf("\n")>-1&&(s?u=u.split("\n").map(function(e){return"  "+e}).join("\n").substr(2):u="\n"+u.split("\n").map(function(e){return"   "+e}).join("\n"))):u=e.stylize("[Circular]","special"));if(typeof o=="undefined"){if(s&&i.match(/^\d+$/))return u;o=JSON.stringify(""+i),o.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)?(o=o.substr(1,o.length-2),o=e.stylize(o,"name")):(o=o.replace(/'/g,"\\'").replace(/\\"/g,'"').replace(/(^"|"$)/g,"'"),o=e.stylize(o,"string"))}return o+": "+u}function p(e,t,n){var r=0,i=e.reduce(function(e,t){return r++,t.indexOf("\n")>=0&&r++,e+t.length+1},0);return i>60?n[0]+(t===""?"":t+"\n ")+" "+e.join(",\n  ")+" "+n[1]:n[0]+t+" "+e.join(", ")+" "+n[1]}function d(e){return Array.isArray(e)||typeof e=="object"&&y(e)==="[object Array]"}function v(e){return typeof e=="object"&&y(e)==="[object RegExp]"}function m(e){return typeof e=="object"&&y(e)==="[object Date]"}function g(e){return typeof e=="object"&&y(e)==="[object Error]"}function y(e){return Object.prototype.toString.call(e)}var r=t("./getName"),i=t("./getProperties"),s=t("./getEnumerableProperties");n.exports=o;var u=function(e){return typeof HTMLElement=="object"?e instanceof HTMLElement:e&&typeof e=="object"&&e.nodeType===1&&typeof e.nodeName=="string"}}),require.register("chai/lib/chai/utils/objDisplay.js",function(e,t,n){var r=t("./inspect"),i=t("../config");n.exports=function(e){var t=r(e),n=Object.prototype.toString.call(e);if(i.truncateThreshold&&t.length>=i.truncateThreshold){if(n==="[object Function]")return!e.name||e.name===""?"[Function]":"[Function: "+e.name+"]";if(n==="[object Array]")return"[ Array("+e.length+") ]";if(n==="[object Object]"){var s=Object.keys(e),o=s.length>2?s.splice(0,2).join(", ")+", ...":s.join(", ");return"{ Object ("+o+") }"}return t}return t}}),require.register("chai/lib/chai/utils/overwriteMethod.js",function(e,t,n){n.exports=function(e,t,n){var r=e[t],i=function(){return this};r&&"function"==typeof r&&(i=r),e[t]=function(){var e=n(i).apply(this,arguments);return e===undefined?this:e}}}),require.register("chai/lib/chai/utils/overwriteProperty.js",function(e,t,n){n.exports=function(e,t,n){var r=Object.getOwnPropertyDescriptor(e,t),i=function(){};r&&"function"==typeof r.get&&(i=r.get),Object.defineProperty(e,t,{get:function(){var e=n(i).call(this);return e===undefined?this:e},configurable:!0})}}),require.register("chai/lib/chai/utils/overwriteChainableMethod.js",function(e,t,n){n.exports=function(e,t,n,r){var i=e.__methods[t],s=i.chainingBehavior;i.chainingBehavior=function(){var e=r(s).call(this);return e===undefined?this:e};var o=i.method;i.method=function(){var e=n(o).apply(this,arguments);return e===undefined?this:e}}}),require.register("chai/lib/chai/utils/test.js",function(e,t,n){var r=t("./flag");n.exports=function(e,t){var n=r(e,"negate"),i=t[0];return n?!i:i}}),require.register("chai/lib/chai/utils/transferFlags.js",function(e,t,n){n.exports=function(e,t,n){var r=e.__flags||(e.__flags=Object.create(null));t.__flags||(t.__flags=Object.create(null)),n=arguments.length===3?n:!0;for(var i in r)if(n||i!=="object"&&i!=="ssfi"&&i!="message")t.__flags[i]=r[i]}}),require.register("chai/lib/chai/utils/type.js",function(e,t,n){var r={"[object Arguments]":"arguments","[object Array]":"array","[object Date]":"date","[object Function]":"function","[object Number]":"number","[object RegExp]":"regexp","[object String]":"string"};n.exports=function(e){var t=Object.prototype.toString.call(e);return r[t]?r[t]:e===null?"null":e===undefined?"undefined":e===Object(e)?"object":typeof e}}),require.alias("chaijs-assertion-error/index.js","chai/deps/assertion-error/index.js"),require.alias("chaijs-assertion-error/index.js","chai/deps/assertion-error/index.js"),require.alias("chaijs-assertion-error/index.js","assertion-error/index.js"),require.alias("chaijs-assertion-error/index.js","chaijs-assertion-error/index.js"),require.alias("chaijs-deep-eql/lib/eql.js","chai/deps/deep-eql/lib/eql.js"),require.alias("chaijs-deep-eql/lib/eql.js","chai/deps/deep-eql/index.js"),require.alias("chaijs-deep-eql/lib/eql.js","deep-eql/index.js"),require.alias("chaijs-type-detect/lib/type.js","chaijs-deep-eql/deps/type-detect/lib/type.js"),require.alias("chaijs-type-detect/lib/type.js","chaijs-deep-eql/deps/type-detect/index.js"),require.alias("chaijs-type-detect/lib/type.js","chaijs-type-detect/index.js"),require.alias("chaijs-deep-eql/lib/eql.js","chaijs-deep-eql/index.js"),require.alias("chai/index.js","chai/index.js"),typeof exports=="object"?module.exports=require("chai"):typeof define=="function"&&define.amd?define([],function(){return require("chai")}):this.chai=require("chai")})();