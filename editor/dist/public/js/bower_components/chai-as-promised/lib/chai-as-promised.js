(function(){function e(t,n){function s(e){return typeof e.always=="function"&&typeof e.done=="function"&&typeof e.fail=="function"&&typeof e.pipe=="function"&&typeof e.progress=="function"&&typeof e.state=="function"}function o(e){if(typeof e._obj.then!="function")throw new TypeError(n.inspect(e._obj)+" is not a thenable.");if(s(e._obj))throw new TypeError("Chai as Promised is incompatible with jQuery's thenables, sorry! Please use a Promises/A+ compatible library (see http://promisesaplus.com/).")}function u(e,t){n.addMethod(r.prototype,e,function(){return o(this),t.apply(this,arguments)})}function a(e,t){n.addProperty(r.prototype,e,function(){return o(this),t.apply(this,arguments)})}function f(e,t){e.then(function(){t()},t)}function l(e,t,n){e.assert(!0,null,t,n.expected,n.actual)}function c(e,t,n){e.assert(!1,t,null,n.expected,n.actual)}function h(e){return typeof e.then=="function"?e:e._obj}function g(t,r,i){if(!n.flag(r,"eventually"))return t.apply(r,i);var s=h(r).then(function(e){return r._obj=e,n.flag(r,"eventually",!1),t.apply(r,i),r._obj});e.transferPromiseness(r,s)}var r=t.Assertion,i=t.assert,p=Object.getOwnPropertyNames(r.prototype),d={};p.forEach(function(e){d[e]=Object.getOwnPropertyDescriptor(r.prototype,e)}),a("fulfilled",function(){var t=this,n=h(t).then(function(e){return t._obj=e,l(t,"expected promise not to be fulfilled but it was fulfilled with #{act}",{actual:e}),e},function(e){c(t,"expected promise to be fulfilled but it was rejected with #{act}",{actual:e})});e.transferPromiseness(t,n)}),a("rejected",function(){var t=this,n=h(t).then(function(e){return t._obj=e,c(t,"expected promise to be rejected but it was fulfilled with #{act}",{actual:e}),e},function(e){return l(t,"expected promise not to be rejected but it was rejected with #{act}",{actual:e}),e});e.transferPromiseness(t,n)}),u("rejectedWith",function(t,r){var i=null,s=null;t instanceof RegExp||typeof t=="string"?(r=t,t=null):t&&t instanceof Error?(i=t,t=null,r=null):typeof t=="function"?s=(new t).name:t=null;var o=this,u=h(o).then(function(e){var n=null,u=null;if(t)n="expected promise to be rejected with #{exp} but it was fulfilled with #{act}",u=s;else if(r){var a=r instanceof RegExp?"matching":"including";n="expected promise to be rejected with an error "+a+" #{exp} but it "+"was fulfilled with #{act}",u=r}else i&&(n="expected promise to be rejected with #{exp} but it was fulfilled with #{act}",u=i);o._obj=e,c(o,n,{expected:u,actual:e})},function(e){t&&o.assert(e instanceof t,"expected promise to be rejected with #{exp} but it was rejected with #{act}","expected promise not to be rejected with #{exp} but it was rejected with #{act}",s,e);var u=n.type(e)==="object"&&"message"in e?e.message:""+e;r&&u!==null&&u!==undefined&&(r instanceof RegExp&&o.assert(r.test(u),"expected promise to be rejected with an error matching #{exp} but got #{act}","expected promise not to be rejected with an error matching #{exp}",r,u),typeof r=="string"&&o.assert(u.indexOf(r)!==-1,"expected promise to be rejected with an error including #{exp} but got #{act}","expected promise not to be rejected with an error including #{exp}",r,u)),i&&o.assert(e===i,"expected promise to be rejected with #{exp} but it was rejected with #{act}","expected promise not to be rejected with #{exp}",i,e)});e.transferPromiseness(o,u)}),a("eventually",function(){n.flag(this,"eventually",!0)}),u("notify",function(e){f(h(this),e)}),u("become",function(e){return this.eventually.deep.equal(e)});var v=p.filter(function(e){return e!=="assert"&&typeof d[e].value=="function"});v.forEach(function(e){r.overwriteMethod(e,function(e){return function(){g(e,this,arguments)}})});var m=p.filter(function(e){return e!=="_obj"&&typeof d[e].get=="function"});m.forEach(function(e){var t=d[e],n=!1;try{n=typeof t.get.call({})=="function"}catch(i){}n?r.addChainableMethod(e,function(){function n(){return t.get.call(e).apply(e,arguments)}var e=this;g(n,this,arguments)},function(){var e=t.get;g(e,this)}):r.overwriteProperty(e,function(e){return function(){g(e,this)}})});var y=Object.getOwnPropertyNames(i).filter(function(e){return typeof i[e]=="function"});i.isFulfilled=function(e,t){return(new r(e,t)).to.be.fulfilled},i.isRejected=function(e,t,n){typeof t=="string"&&(n=t,t=undefined);var i=new r(e,n);return t!==undefined?i.to.be.rejectedWith(t):i.to.be.rejected},i.becomes=function(e,t,n){return i.eventually.deepEqual(e,t,n)},i.doesNotBecome=function(e,t,n){return i.eventually.notDeepEqual(e,t,n)},i.eventually={},y.forEach(function(e){i.eventually[e]=function(r){var s=Array.prototype.slice.call(arguments,1),o,u=arguments[i[e].length-1];typeof u=="string"&&(o=function(e){throw new t.AssertionError(u+"\n\nOriginal reason: "+n.inspect(e))});var a=r.then(function(t){return i[e].apply(i,[t].concat(s))},o);return a.notify=function(e){f(a,e)},a}})}typeof require=="function"&&typeof exports=="object"&&typeof module=="object"?module.exports=e:typeof define=="function"&&define.amd?define([],function(){return e}):(chai.use(e),self.chaiAsPromised=e),e.transferPromiseness=function(e,t){e.then=t.then.bind(t)}})();