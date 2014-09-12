/**
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2010-2014 Christian Johansen
 */

if(typeof require=="function"&&typeof module=="object")var buster=require("../runner"),sinon=require("../../lib/sinon");(function(){function e(e){return{setUp:function(){this.spy=sinon.spy.create()},"returns false if spy was not called":function(){assert.isFalse(this.spy[e](1,2,3))},"returns true if spy was called with args":function(){this.spy(1,2,3),assert(this.spy[e](1,2,3))},"returns true if called with args at least once":function(){this.spy(1,3,3),this.spy(1,2,3),this.spy(3,2,3),assert(this.spy[e](1,2,3))},"returns false if not called with args":function(){this.spy(1,3,3),this.spy(2),this.spy(),assert.isFalse(this.spy[e](1,2,3))},"returns true for partial match":function(){this.spy(1,3,3),this.spy(2),this.spy(),assert(this.spy[e](1,3))},"matchs all arguments individually, not as array":function(){this.spy([1,2,3]),assert.isFalse(this.spy[e](1,2,3))},"uses matcher":function(){this.spy("abc"),assert(this.spy[e](sinon.match.typeOf("string")))},"uses matcher in object":function(){this.spy({some:"abc"}),assert(this.spy[e]({some:sinon.match.typeOf("string")}))}}}function t(e){return{setUp:function(){this.spy=sinon.spy.create()},"returns false if spy was not called":function(){assert.isFalse(this.spy[e](1,2,3))},"returns true if spy was called with args":function(){this.spy(1,2,3),assert(this.spy[e](1,2,3))},"returns false if called with args only once":function(){this.spy(1,3,3),this.spy(1,2,3),this.spy(3,2,3),assert.isFalse(this.spy[e](1,2,3))},"returns false if not called with args":function(){this.spy(1,3,3),this.spy(2),this.spy(),assert.isFalse(this.spy[e](1,2,3))},"returns true for partial match":function(){this.spy(1,3,3),assert(this.spy[e](1,3))},"returns true for partial match on many calls":function(){this.spy(1,3,3),this.spy(1,3),this.spy(1,3,4,5),this.spy(1,3,1),assert(this.spy[e](1,3))},"matchs all arguments individually, not as array":function(){this.spy([1,2,3]),assert.isFalse(this.spy[e](1,2,3))}}}function n(e){return{setUp:function(){this.spy=sinon.spy.create()},"returns true if spy was not called":function(){assert(this.spy[e](1,2,3))},"returns false if spy was called with args":function(){this.spy(1,2,3),assert.isFalse(this.spy[e](1,2,3))},"returns false if called with args at least once":function(){this.spy(1,3,3),this.spy(1,2,3),this.spy(3,2,3),assert.isFalse(this.spy[e](1,2,3))},"returns true if not called with args":function(){this.spy(1,3,3),this.spy(2),this.spy(),assert(this.spy[e](1,2,3))},"returns false for partial match":function(){this.spy(1,3,3),this.spy(2),this.spy(),assert.isFalse(this.spy[e](1,3))},"matchs all arguments individually, not as array":function(){this.spy([1,2,3]),assert(this.spy[e](1,2,3))}}}buster.testCase("sinon.spy",{"does not throw if called without function":function(){refute.exception(function(){sinon.spy.create()})},"does not throw when calling anonymous spy":function(){var e=sinon.spy.create();refute.exception(function(){e()}),assert(e.called)},"returns spy function":function(){var e=function(){},t=sinon.spy.create(e);assert.isFunction(t),refute.same(e,t)},"mirrors custom properties on function":function(){var e=function(){};e.myProp=42;var t=sinon.spy.create(e);assert.equals(t.myProp,e.myProp)},"does not define create method":function(){var e=sinon.spy.create();refute.defined(e.create)},"does not overwrite original create property":function(){var e=function(){},t=e.create={},n=sinon.spy.create(e);assert.same(n.create,t)},"setups logging arrays":function(){var e=sinon.spy.create();assert.isArray(e.args),assert.isArray(e.returnValues),assert.isArray(e.thisValues),assert.isArray(e.exceptions)},named:{"sets displayName":function(){var e=sinon.spy(),t=e.named("beep");assert.equals(e.displayName,"beep"),assert.same(e,t)}},call:{"calls underlying function":function(){var e=!1,t=sinon.spy.create(function(){e=!0});t(),assert(e)},"passs arguments to function":function(){var e,t=function(t,n,r,i){e=[t,n,r,i]},n=[1,{},[],""],r=sinon.spy.create(t);r(n[0],n[1],n[2],n[3]),assert.equals(e,n)},"maintains this binding":function(){var e,t=function(){e=this},n={},r=sinon.spy.create(t);r.call(n),assert.same(e,n)},"returns function's return value":function(){var e={},t=function(){return e},n=sinon.spy.create(t),r=n();assert.same(r,e)},"throws if function throws":function(){var e=new Error,t=sinon.spy.create(function(){throw e});try{t(),buster.assertions.fail("Expected spy to throw exception")}catch(n){assert.same(n,e)}},"retains function length 0":function(){var e=sinon.spy.create(function(){});assert.equals(e.length,0)},"retains function length 1":function(){var e=sinon.spy.create(function(e){});assert.equals(e.length,1)},"retains function length 2":function(){var e=sinon.spy.create(function(e,t){});assert.equals(e.length,2)},"retains function length 3":function(){var e=sinon.spy.create(function(e,t,n){});assert.equals(e.length,3)},"retains function length 4":function(){var e=sinon.spy.create(function(e,t,n,r){});assert.equals(e.length,4)},"retains function length 12":function(){var e=sinon.spy.create(function(e,t,n,r,i,s,o,u,a,f,l,c){});assert.equals(e.length,12)}},called:{setUp:function(){this.spy=sinon.spy.create()},"is false prior to calling the spy":function(){assert.isFalse(this.spy.called)},"is true after calling the spy once":function(){this.spy(),assert(this.spy.called)},"is true after calling the spy twice":function(){this.spy(),this.spy(),assert(this.spy.called)}},notCalled:{setUp:function(){this.spy=sinon.spy.create()},"is true prior to calling the spy":function(){assert.isTrue(this.spy.notCalled)},"is false after calling the spy once":function(){this.spy(),assert.isFalse(this.spy.notCalled)}},calledOnce:{setUp:function(){this.spy=sinon.spy.create()},"is false prior to calling the spy":function(){assert.isFalse(this.spy.calledOnce)},"is true after calling the spy once":function(){this.spy(),assert(this.spy.calledOnce)},"is false after calling the spy twice":function(){this.spy(),this.spy(),assert.isFalse(this.spy.calledOnce)}},calledTwice:{setUp:function(){this.spy=sinon.spy.create()},"is false prior to calling the spy":function(){assert.isFalse(this.spy.calledTwice)},"is false after calling the spy once":function(){this.spy(),assert.isFalse(this.spy.calledTwice)},"is true after calling the spy twice":function(){this.spy(),this.spy(),assert(this.spy.calledTwice)},"is false after calling the spy thrice":function(){this.spy(),this.spy(),this.spy(),assert.isFalse(this.spy.calledTwice)}},calledThrice:{setUp:function(){this.spy=sinon.spy.create()},"is false prior to calling the spy":function(){assert.isFalse(this.spy.calledThrice)},"is false after calling the spy twice":function(){this.spy(),this.spy(),assert.isFalse(this.spy.calledThrice)},"is true after calling the spy thrice":function(){this.spy(),this.spy(),this.spy(),assert(this.spy.calledThrice)},"is false after calling the spy four times":function(){this.spy(),this.spy(),this.spy(),this.spy(),assert.isFalse(this.spy.calledThrice)}},callCount:{setUp:function(){this.spy=sinon.spy.create()},"reports 0 calls":function(){assert.equals(this.spy.callCount,0)},"records one call":function(){this.spy(),assert.equals(this.spy.callCount,1)},"records two calls":function(){this.spy(),this.spy(),assert.equals(this.spy.callCount,2)},"increases call count for each call":function(){this.spy(),this.spy(),assert.equals(this.spy.callCount,2),this.spy(),assert.equals(this.spy.callCount,3)}},calledOn:{setUp:function(){this.spy=sinon.spy.create()},"is false if spy wasn't called":function(){assert.isFalse(this.spy.calledOn({}))},"is true if called with thisValue":function(){var e={};this.spy.call(e),assert(this.spy.calledOn(e))},browser:{requiresSupportFor:{browser:typeof window!="undefined"},"is true if called on object at least once":function(){var e={};this.spy(),this.spy.call({}),this.spy.call(e),this.spy.call(window),assert(this.spy.calledOn(e))}},"returns false if not called on object":function(){var e={};this.spy.call(e),this.spy(),assert.isFalse(this.spy.calledOn({}))},"is true if called with matcher that returns true":function(){var e=sinon.match(function(){return!0});this.spy(),assert(this.spy.calledOn(e))},"is false if called with matcher that returns false":function(){var e=sinon.match(function(){return!1});this.spy(),assert.isFalse(this.spy.calledOn(e))},"invokes matcher.test with given object":function(){var e={},t;this.spy.call(e),this.spy.calledOn(sinon.match(function(e){t=e})),assert.same(t,e)}},alwaysCalledOn:{setUp:function(){this.spy=sinon.spy.create()},"is false prior to calling the spy":function(){assert.isFalse(this.spy.alwaysCalledOn({}))},"is true if called with thisValue once":function(){var e={};this.spy.call(e),assert(this.spy.alwaysCalledOn(e))},"is true if called with thisValue many times":function(){var e={};this.spy.call(e),this.spy.call(e),this.spy.call(e),this.spy.call(e),assert(this.spy.alwaysCalledOn(e))},"is false if called with another object atleast once":function(){var e={};this.spy.call(e),this.spy.call(e),this.spy.call(e),this.spy(),this.spy.call(e),assert.isFalse(this.spy.alwaysCalledOn(e))},"is false if never called with expected object":function(){var e={};this.spy(),this.spy(),this.spy(),assert.isFalse(this.spy.alwaysCalledOn(e))}},calledWithNew:{setUp:function(){this.spy=sinon.spy.create()},"is false if spy wasn't called":function(){assert.isFalse(this.spy.calledWithNew())},"is true if called with new":function(){var e=new this.spy;assert(this.spy.calledWithNew())},"is true if called with new on custom constructor":function(){function e(){}e.prototype={};var t={MyThing:e};sinon.spy(t,"MyThing");var n=new t.MyThing;assert(t.MyThing.calledWithNew())},"is false if called as function":function(){this.spy(),assert.isFalse(this.spy.calledWithNew())},browser:{requiresSupportFor:{browser:typeof window!="undefined"},"is true if called with new at least once":function(){var e={};this.spy();var t=new this.spy;this.spy(e),this.spy(window),assert(this.spy.calledWithNew())}},"is true newed constructor returns object":function(){function e(){return{}}var t={MyThing:e};sinon.spy(t,"MyThing");var n=new t.MyThing;assert(t.MyThing.calledWithNew())},"spied native function":{requiresSupportFor:{applyableNatives:function(){try{return console.log.apply({},[]),!0}catch(e){return!1}}},"is false when called on spied native function":function(){var e={info:console.log};sinon.spy(e,"info"),e.info("test"),assert.isFalse(e.info.calledWithNew())}}},alwaysCalledWithNew:{setUp:function(){this.spy=sinon.spy.create()},"is false if spy wasn't called":function(){assert.isFalse(this.spy.alwaysCalledWithNew())},"is true if always called with new":function(){var e=new this.spy,t=new this.spy,n=new this.spy;assert(this.spy.alwaysCalledWithNew())},"is false if called as function once":function(){var e=new this.spy,t=new this.spy;this.spy(),assert.isFalse(this.spy.alwaysCalledWithNew())}},thisValue:{setUp:function(){this.spy=sinon.spy.create()},"contains one object":function(){var e={};this.spy.call(e),assert.equals(this.spy.thisValues,[e])},"stacks up objects":function(){function e(){}var t=[{},[],new e,{id:243}];this.spy(),this.spy.call(t[0]),this.spy.call(t[1]),this.spy.call(t[2]),this.spy.call(t[3]),assert.equals(this.spy.thisValues,[this].concat(t))}},calledWith:e("calledWith"),calledWithMatch:e("calledWithMatch"),calledWithMatchSpecial:{setUp:function(){this.spy=sinon.spy.create()},"checks substring match":function(){this.spy("I like it"),assert(this.spy.calledWithMatch("like")),assert.isFalse(this.spy.calledWithMatch("nope"))},"checks for regexp match":function(){this.spy("I like it"),assert(this.spy.calledWithMatch(/[a-z ]+/i)),assert.isFalse(this.spy.calledWithMatch(/[0-9]+/))},"checks for partial object match":function(){this.spy({foo:"foo",bar:"bar"}),assert(this.spy.calledWithMatch({bar:"bar"})),assert.isFalse(this.spy.calledWithMatch({same:"same"}))}},alwaysCalledWith:t("alwaysCalledWith"),alwaysCalledWithMatch:t("alwaysCalledWithMatch"),alwaysCalledWithMatchSpecial:{setUp:function(){this.spy=sinon.spy.create()},"checks true":function(){this.spy(!0),assert(this.spy.alwaysCalledWithMatch(!0)),assert.isFalse(this.spy.alwaysCalledWithMatch(!1))},"checks false":function(){this.spy(!1),assert(this.spy.alwaysCalledWithMatch(!1)),assert.isFalse(this.spy.alwaysCalledWithMatch(!0))},"checks substring match":function(){this.spy("test case"),this.spy("some test"),this.spy("all tests"),assert(this.spy.alwaysCalledWithMatch("test")),assert.isFalse(this.spy.alwaysCalledWithMatch("case"))},"checks regexp match":function(){this.spy("1"),this.spy("2"),this.spy("3"),assert(this.spy.alwaysCalledWithMatch(/[123]/)),assert.isFalse(this.spy.alwaysCalledWithMatch(/[12]/))},"checks partial object match":function(){this.spy({a:"a",b:"b"}),this.spy({c:"c",b:"b"}),this.spy({b:"b",d:"d"}),assert(this.spy.alwaysCalledWithMatch({b:"b"})),assert.isFalse(this.spy.alwaysCalledWithMatch({a:"a"}))}},neverCalledWith:n("neverCalledWith"),neverCalledWithMatch:n("neverCalledWithMatch"),neverCalledWithMatchSpecial:{setUp:function(){this.spy=sinon.spy.create()},"checks substring match":function(){this.spy("a test","b test"),assert(this.spy.neverCalledWithMatch("a","a")),assert(this.spy.neverCalledWithMatch("b","b")),assert(this.spy.neverCalledWithMatch("b","a")),assert.isFalse(this.spy.neverCalledWithMatch("a","b"))},"checks regexp match":function(){this.spy("a test","b test"),assert(this.spy.neverCalledWithMatch(/a/,/a/)),assert(this.spy.neverCalledWithMatch(/b/,/b/)),assert(this.spy.neverCalledWithMatch(/b/,/a/)),assert.isFalse(this.spy.neverCalledWithMatch(/a/,/b/))},"checks partial object match":function(){this.spy({a:"test",b:"test"}),assert(this.spy.neverCalledWithMatch({a:"nope"})),assert(this.spy.neverCalledWithMatch({c:"test"})),assert.isFalse(this.spy.neverCalledWithMatch({b:"test"}))}},args:{setUp:function(){this.spy=sinon.spy.create()},"contains real arrays":function(){this.spy(),assert.isArray(this.spy.args[0])},"contains empty array when no arguments":function(){this.spy(),assert.equals(this.spy.args,[[]])},"contains array with first call's arguments":function(){this.spy(1,2,3),assert.equals(this.spy.args,[[1,2,3]])},"stacks up arguments in nested array":function(){var e=[{},[],{id:324}];this.spy(1,e[0],3),this.spy(1,2,e[1]),this.spy(e[2],2,3),assert.equals(this.spy.args,[[1,e[0],3],[1,2,e[1]],[e[2],2,3]])}},calledWithExactly:{setUp:function(){this.spy=sinon.spy.create()},"returns false for partial match":function(){this.spy(1,2,3),assert.isFalse(this.spy.calledWithExactly(1,2))},"returns false for missing arguments":function(){this.spy(1,2,3),assert.isFalse(this.spy.calledWithExactly(1,2,3,4))},"returns true for exact match":function(){this.spy(1,2,3),assert(this.spy.calledWithExactly(1,2,3))},"matchs by strict comparison":function(){this.spy({},[]),assert.isFalse(this.spy.calledWithExactly({},[],null))},"returns true for one exact match":function(){var e={},t=[];this.spy({},[]),this.spy(e,[]),this.spy(e,t),assert(this.spy.calledWithExactly(e,t))},"returns true when all properties of an object argument match":function(){this.spy({a:1,b:2,c:3}),assert(this.spy.calledWithExactly({a:1,b:2,c:3}))},"returns false when a property of an object argument is set to undefined":function(){this.spy({a:1,b:2,c:3}),assert.isFalse(this.spy.calledWithExactly({a:1,b:2,c:undefined}))},"returns false when a property of an object argument is set to a different value":function(){this.spy({a:1,b:2,c:3}),assert.isFalse(this.spy.calledWithExactly({a:1,b:2,c:"blah"}))},"returns false when an object argument has a different property/value pair":function(){this.spy({a:1,b:2,c:3}),assert.isFalse(this.spy.calledWithExactly({a:1,b:2,foo:"blah"}))},"returns false when a property of an object argument is set to undefined and has a different name":function(){this.spy({a:1,b:2,c:3}),assert.isFalse(this.spy.calledWithExactly({a:1,b:2,foo:undefined}))},"returns false when any properties of an object argument aren't present":function(){this.spy({a:1,b:2,c:3}),assert.isFalse(this.spy.calledWithExactly({a:1,b:2}))},"returns false when an object argument has extra properties":function(){this.spy({a:1,b:2,c:3}),assert.isFalse(this.spy.calledWithExactly({a:1,b:2,c:3,d:4}))}},alwaysCalledWithExactly:{setUp:function(){this.spy=sinon.spy.create()},"returns false for partial match":function(){this.spy(1,2,3),assert.isFalse(this.spy.alwaysCalledWithExactly(1,2))},"returns false for missing arguments":function(){this.spy(1,2,3),assert.isFalse(this.spy.alwaysCalledWithExactly(1,2,3,4))},"returns true for exact match":function(){this.spy(1,2,3),assert(this.spy.alwaysCalledWithExactly(1,2,3))},"returns false for excess arguments":function(){this.spy({},[]),assert.isFalse(this.spy.alwaysCalledWithExactly({},[],null))},"returns false for one exact match":function(){var e={},t=[];this.spy({},[]),this.spy(e,[]),this.spy(e,t),assert(this.spy.alwaysCalledWithExactly(e,t))},"returns true for only exact matches":function(){var e={},t=[];this.spy(e,t),this.spy(e,t),this.spy(e,t),assert(this.spy.alwaysCalledWithExactly(e,t))},"returns false for no exact matches":function(){var e={},t=[];this.spy(e,t,null),this.spy(e,t,undefined),this.spy(e,t,""),assert.isFalse(this.spy.alwaysCalledWithExactly(e,t))}},threw:{setUp:function(){this.spy=sinon.spy.create(),this.spyWithTypeError=sinon.spy.create(function(){throw new TypeError}),this.spyWithStringError=sinon.spy.create(function(){throw"error"})},"returns exception thrown by function":function(){var e=new Error,t=sinon.spy.create(function(){throw e});try{t()}catch(n){}assert(t.threw(e))},"returns false if spy did not throw":function(){this.spy(),assert.isFalse(this.spy.threw())},"returns true if spy threw":function(){try{this.spyWithTypeError()}catch(e){}assert(this.spyWithTypeError.threw())},"returns true if string type matches":function(){try{this.spyWithTypeError()}catch(e){}assert(this.spyWithTypeError.threw("TypeError"))},"returns false if string did not match":function(){try{this.spyWithTypeError()}catch(e){}assert.isFalse(this.spyWithTypeError.threw("Error"))},"returns false if spy did not throw specified error":function(){this.spy(),assert.isFalse(this.spy.threw("Error"))},"returns true if string matches":function(){try{this.spyWithStringError()}catch(e){}assert(this.spyWithStringError.threw("error"))},"returns false if strings do not match":function(){try{this.spyWithStringError()}catch(e){}assert.isFalse(this.spyWithStringError.threw("not the error"))}},alwaysThrew:{setUp:function(){this.spy=sinon.spy.create(),this.spyWithTypeError=sinon.spy.create(function(){throw new TypeError})},"returns true when spy threw":function(){var e=new Error,t=sinon.spy.create(function(){throw e});try{t()}catch(n){}assert(t.alwaysThrew(e))},"returns false if spy did not throw":function(){this.spy(),assert.isFalse(this.spy.alwaysThrew())},"returns true if spy threw":function(){try{this.spyWithTypeError()}catch(e){}assert(this.spyWithTypeError.alwaysThrew())},"returns true if string type matches":function(){try{this.spyWithTypeError()}catch(e){}assert(this.spyWithTypeError.alwaysThrew("TypeError"))},"returns false if string did not match":function(){try{this.spyWithTypeError()}catch(e){}assert.isFalse(this.spyWithTypeError.alwaysThrew("Error"))},"returns false if spy did not throw specified error":function(){this.spy(),assert.isFalse(this.spy.alwaysThrew("Error"))},"returns false if some calls did not throw":function(){var e=sinon.stub.create(function(){if(e.callCount===0)throw new Error});try{this.spy()}catch(t){}this.spy(),assert.isFalse(this.spy.alwaysThrew())},"returns true if all calls threw":function(){try{this.spyWithTypeError()}catch(e){}try{this.spyWithTypeError()}catch(t){}assert(this.spyWithTypeError.alwaysThrew())},"returns true if all calls threw same type":function(){try{this.spyWithTypeError()}catch(e){}try{this.spyWithTypeError()}catch(t){}assert(this.spyWithTypeError.alwaysThrew("TypeError"))}},exceptions:{setUp:function(){this.spy=sinon.spy.create();var e=this.error={};this.spyWithTypeError=sinon.spy.create(function(){throw e})},"contains exception thrown by function":function(){try{this.spyWithTypeError()}catch(e){}assert.equals(this.spyWithTypeError.exceptions,[this.error])},"contains undefined entry when function did not throw":function(){this.spy(),assert.equals(this.spy.exceptions.length,1),refute.defined(this.spy.exceptions[0])},"stacks up exceptions and undefined":function(){var e=0,t=this.error,n=sinon.spy.create(function(){e+=1;if(e%2===0)throw t});n();try{n()}catch(r){}n();try{n()}catch(i){}n(),assert.equals(n.exceptions.length,5),refute.defined(n.exceptions[0]),assert.equals(n.exceptions[1],t),refute.defined(n.exceptions[2]),assert.equals(n.exceptions[3],t),refute.defined(n.exceptions[4])}},returned:{"returns true when no argument":function(){var e=sinon.spy.create();e(),assert(e.returned())},"returns true for undefined when no explicit return":function(){var e=sinon.spy.create();e(),assert(e.returned(undefined))},"returns true when returned value once":function(){var e=[{},2,"hey",function(){}],t=sinon.spy.create(function(){return e[t.callCount]});t(),t(),t(),t(),assert(t.returned(e[3]))},"returns false when value is never returned":function(){var e=[{},2,"hey",function(){}],t=sinon.spy.create(function(){return e[t.callCount]});t(),t(),t(),t(),assert.isFalse(t.returned({id:42}))},"returns true when value is returned several times":function(){var e={id:42},t=sinon.spy.create(function(){return e});t(),t(),t(),assert(t.returned(e))},"compares values deeply":function(){var e={deep:{id:42}},t=sinon.spy.create(function(){return e});t(),assert(t.returned({deep:{id:42}}))},"compares values strictly using match.same":function(){var e={id:42},t=sinon.spy.create(function(){return e});t(),assert.isFalse(t.returned(sinon.match.same({id:42}))),assert(t.returned(sinon.match.same(e)))}},returnValues:{"contains undefined when function does not return explicitly":function(){var e=sinon.spy.create();e(),assert.equals(e.returnValues.length,1),refute.defined(e.returnValues[0])},"contains return value":function(){var e={id:42},t=sinon.spy.create(function(){return e});t(),assert.equals(t.returnValues,[e])},"contains undefined when function throws":function(){var e=sinon.spy.create(function(){throw new Error});try{e()}catch(t){}assert.equals(e.returnValues.length,1),refute.defined(e.returnValues[0])},"contains the created object for spied constructors":function(){var e=sinon.spy.create(function(){}),t=new e;assert.equals(e.returnValues[0],t)},"contains the return value for spied constructors that explicitly return objects":function(){var e=sinon.spy.create(function(){return{isExplicitlyCreatedValue:!0}}),t=new e;assert.isTrue(t.isExplicitlyCreatedValue),assert.equals(e.returnValues[0],t)},"contains the created object for spied constructors that explicitly return primitive values":function(){var e=sinon.spy.create(function(){return 10}),t=new e;refute.equals(t,10),assert.equals(e.returnValues[0],t)},"stacks up return values":function(){var e=0,t=sinon.spy.create(function(){e+=1;if(e%2===0)return e});t(),t(),t(),t(),t(),assert.equals(t.returnValues.length,5),refute.defined(t.returnValues[0]),assert.equals(t.returnValues[1],2),refute.defined(t.returnValues[2]),assert.equals(t.returnValues[3],4),refute.defined(t.returnValues[4])}},calledBefore:{setUp:function(){this.spy1=sinon.spy(),this.spy2=sinon.spy()},"is function":function(){assert.isFunction(this.spy1.calledBefore)},"returns true if first call to A was before first to B":function(){this.spy1(),this.spy2(),assert(this.spy1.calledBefore(this.spy2))},"compares call order of calls directly":function(){this.spy1(),this.spy2(),assert(this.spy1.getCall(0).calledBefore(this.spy2.getCall(0)))},"returns false if not called":function(){this.spy2(),assert.isFalse(this.spy1.calledBefore(this.spy2))},"returns true if other not called":function(){this.spy1(),assert(this.spy1.calledBefore(this.spy2))},"returns false if other called first":function(){this.spy2(),this.spy1(),this.spy2(),assert(this.spy1.calledBefore(this.spy2))}},calledAfter:{setUp:function(){this.spy1=sinon.spy(),this.spy2=sinon.spy()},"is function":function(){assert.isFunction(this.spy1.calledAfter)},"returns true if first call to A was after first to B":function(){this.spy2(),this.spy1(),assert(this.spy1.calledAfter(this.spy2))},"compares calls directly":function(){this.spy2(),this.spy1(),assert(this.spy1.getCall(0).calledAfter(this.spy2.getCall(0)))},"returns false if not called":function(){this.spy2(),assert.isFalse(this.spy1.calledAfter(this.spy2))},"returns false if other not called":function(){this.spy1(),assert.isFalse(this.spy1.calledAfter(this.spy2))},"returns false if other called last":function(){this.spy2(),this.spy1(),this.spy2(),assert.isFalse(this.spy1.calledAfter(this.spy2))}},firstCall:{"is undefined by default":function(){var e=sinon.spy();assert.isNull(e.firstCall)},"is equal to getCall(0) result after first call":function(){var e=sinon.spy();e();var t=e.getCall(0);assert.equals(e.firstCall.callId,t.callId),assert.same(e.firstCall.spy,t.spy)},"is tracked even if exceptions are thrown":function(){var e=sinon.spy(function(){throw"an exception"});try{e()}catch(t){}refute.isNull(e.firstCall)}},secondCall:{"is null by default":function(){var e=sinon.spy();assert.isNull(e.secondCall)},"stills be null after first call":function(){var e=sinon.spy();e(),assert.isNull(e.secondCall)},"is equal to getCall(1) result after second call":function(){var e=sinon.spy();e(),e();var t=e.getCall(1);assert.equals(e.secondCall.callId,t.callId),assert.same(e.secondCall.spy,t.spy)}},thirdCall:{"is undefined by default":function(){var e=sinon.spy();assert.isNull(e.thirdCall)},"stills be undefined after second call":function(){var e=sinon.spy();e(),e(),assert.isNull(e.thirdCall)},"is equal to getCall(1) result after second call":function(){var e=sinon.spy();e(),e(),e();var t=e.getCall(2);assert.equals(e.thirdCall.callId,t.callId),assert.same(e.thirdCall.spy,t.spy)}},lastCall:{"is undefined by default":function(){var e=sinon.spy();assert.isNull(e.lastCall)},"is same as firstCall after first call":function(){var e=sinon.spy();e(),assert.same(e.lastCall.callId,e.firstCall.callId),assert.same(e.lastCall.spy,e.firstCall.spy)},"is same as secondCall after second call":function(){var e=sinon.spy();e(),e(),assert.same(e.lastCall.callId,e.secondCall.callId),assert.same(e.lastCall.spy,e.secondCall.spy)},"is same as thirdCall after third call":function(){var e=sinon.spy();e(),e(),e(),assert.same(e.lastCall.callId,e.thirdCall.callId),assert.same(e.lastCall.spy,e.thirdCall.spy)},"is equal to getCall(3) result after fourth call":function(){var e=sinon.spy();e(),e(),e(),e();var t=e.getCall(3);assert.equals(e.lastCall.callId,t.callId),assert.same(e.lastCall.spy,t.spy)},"is equal to getCall(4) result after fifth call":function(){var e=sinon.spy();e(),e(),e(),e(),e();var t=e.getCall(4);assert.equals(e.lastCall.callId,t.callId),assert.same(e.lastCall.spy,t.spy)}},getCalls:{"returns an empty Array by default":function(){var e=sinon.spy();assert.isArray(e.getCalls()),assert.equals(e.getCalls().length,0)},"is analogous to using getCall(n)":function(){var e=sinon.spy();e(),e(),assert.equals(e.getCalls(),[e.getCall(0),e.getCall(1)])}},callArg:{"is function":function(){var e=sinon.spy();assert.isFunction(e.callArg)},"invokes argument at index for all calls":function(){var e=sinon.spy(),t=sinon.spy();e(1,2,t),e(3,4,t),e.callArg(2),assert(t.calledTwice),assert(t.alwaysCalledWith())},"throws if argument at index is not a function":function(){var e=sinon.spy();e(),assert.exception(function(){e.callArg(1)},"TypeError")},"throws if spy was not yet invoked":function(){var e=sinon.spy();try{throw e.callArg(0),new Error}catch(t){assert.equals(t.message,"spy cannot call arg since it was not yet invoked.")}},"includes spy name in error message":function(){var e={someMethod:function(){}},t=sinon.spy(e,"someMethod");try{throw t.callArg(0),new Error}catch(n){assert.equals(n.message,"someMethod cannot call arg since it was not yet invoked.")}},"throws if index is not a number":function(){var e=sinon.spy();e(),assert.exception(function(){e.callArg("")},"TypeError")},"passs additional arguments":function(){var e=sinon.spy(),t=sinon.spy(),n=[],r={};e(t),e.callArg(0,"abc",123,n,r),assert(t.calledWith("abc",123,n,r))}},callArgOn:{"is function":function(){var e=sinon.spy();assert.isFunction(e.callArgOn)},"invokes argument at index for all calls":function(){var e=sinon.spy(),t=sinon.spy(),n={name1:"value1",name2:"value2"};e(1,2,t),e(3,4,t),e.callArgOn(2,n),assert(t.calledTwice),assert(t.alwaysCalledWith()),assert(t.alwaysCalledOn(n))},"throws if argument at index is not a function":function(){var e=sinon.spy(),t={name1:"value1",name2:"value2"};e(),assert.exception(function(){e.callArgOn(1,t)},"TypeError")},"throws if spy was not yet invoked":function(){var e=sinon.spy(),t={name1:"value1",name2:"value2"};try{throw e.callArgOn(0,t),new Error}catch(n){assert.equals(n.message,"spy cannot call arg since it was not yet invoked.")}},"includes spy name in error message":function(){var e={someMethod:function(){}},t=sinon.spy(e,"someMethod"),n={name1:"value1",name2:"value2"};try{throw t.callArgOn(0,n),new Error}catch(r){assert.equals(r.message,"someMethod cannot call arg since it was not yet invoked.")}},"throws if index is not a number":function(){var e=sinon.spy(),t={name1:"value1",name2:"value2"};e(),assert.exception(function(){e.callArg("",t)},"TypeError")},"pass additional arguments":function(){var e=sinon.spy(),t=sinon.spy(),n=[],r={},i={name1:"value1",name2:"value2"};e(t),e.callArgOn(0,i,"abc",123,n,r),assert(t.calledWith("abc",123,n,r)),assert(t.calledOn(i))}},callArgWith:{"is alias for callArg":function(){var e=sinon.spy();assert.same(e.callArgWith,e.callArg)}},callArgOnWith:{"is alias for callArgOn":function(){var e=sinon.spy();assert.same(e.callArgOnWith,e.callArgOn)}},yield:{"is function":function(){var e=sinon.spy();assert.isFunction(e.yield)},"invokes first function arg for all calls":function(){var e=sinon.spy(),t=sinon.spy();e(1,2,t),e(3,4,t),e.yield(),assert(t.calledTwice),assert(t.alwaysCalledWith())},"throws if spy was not yet invoked":function(){var e=sinon.spy();try{throw e.yield(),new Error}catch(t){assert.equals(t.message,"spy cannot yield since it was not yet invoked.")}},"includes spy name in error message":function(){var e={someMethod:function(){}},t=sinon.spy(e,"someMethod");try{throw t.yield(),new Error}catch(n){assert.equals(n.message,"someMethod cannot yield since it was not yet invoked.")}},"passs additional arguments":function(){var e=sinon.spy(),t=sinon.spy(),n=[],r={};e(t),e.yield("abc",123,n,r),assert(t.calledWith("abc",123,n,r))}},invokeCallback:{"is alias for yield":function(){var e=sinon.spy();assert.same(e.invokeCallback,e.yield)}},yieldOn:{"is function":function(){var e=sinon.spy();assert.isFunction(e.yieldOn)},"invokes first function arg for all calls":function(){var e=sinon.spy(),t=sinon.spy(),n={name1:"value1",name2:"value2"};e(1,2,t),e(3,4,t),e.yieldOn(n),assert(t.calledTwice),assert(t.alwaysCalledWith()),assert(t.alwaysCalledOn(n))},"throws if spy was not yet invoked":function(){var e=sinon.spy(),t={name1:"value1",name2:"value2"};try{throw e.yieldOn(t),new Error}catch(n){assert.equals(n.message,"spy cannot yield since it was not yet invoked.")}},"includes spy name in error message":function(){var e={someMethod:function(){}},t=sinon.spy(e,"someMethod"),n={name1:"value1",name2:"value2"};try{throw t.yieldOn(n),new Error}catch(r){assert.equals(r.message,"someMethod cannot yield since it was not yet invoked.")}},"pass additional arguments":function(){var e=sinon.spy(),t=sinon.spy(),n=[],r={},i={name1:"value1",name2:"value2"};e(t),e.yieldOn(i,"abc",123,n,r),assert(t.calledWith("abc",123,n,r)),assert(t.calledOn(i))}},yieldTo:{"is function":function(){var e=sinon.spy();assert.isFunction(e.yieldTo)},"invokes first function arg for all calls":function(){var e=sinon.spy(),t=sinon.spy();e(1,2,{success:t}),e(3,4,{success:t}),e.yieldTo("success"),assert(t.calledTwice),assert(t.alwaysCalledWith())},"throws if spy was not yet invoked":function(){var e=sinon.spy();try{throw e.yieldTo("success"),new Error}catch(t){assert.equals(t.message,"spy cannot yield to 'success' since it was not yet invoked.")}},"includes spy name in error message":function(){var e={someMethod:function(){}},t=sinon.spy(e,"someMethod");try{throw t.yieldTo("success"),new Error}catch(n){assert.equals(n.message,"someMethod cannot yield to 'success' since it was not yet invoked.")}},"pass additional arguments":function(){var e=sinon.spy(),t=sinon.spy(),n=[],r={};e({test:t}),e.yieldTo("test","abc",123,n,r),assert(t.calledWith("abc",123,n,r))}},yieldToOn:{"is function":function(){var e=sinon.spy();assert.isFunction(e.yieldToOn)},"invokes first function arg for all calls":function(){var e=sinon.spy(),t=sinon.spy(),n={name1:"value1",name2:"value2"};e(1,2,{success:t}),e(3,4,{success:t}),e.yieldToOn("success",n),assert(t.calledTwice),assert(t.alwaysCalledWith()),assert(t.alwaysCalledOn(n))},"throws if spy was not yet invoked":function(){var e=sinon.spy(),t={name1:"value1",name2:"value2"};try{throw e.yieldToOn("success",t),new Error}catch(n){assert.equals(n.message,"spy cannot yield to 'success' since it was not yet invoked.")}},"includes spy name in error message":function(){var e={someMethod:function(){}},t=sinon.spy(e,"someMethod"),n={name1:"value1",name2:"value2"};try{throw t.yieldToOn("success",n),new Error}catch(r){assert.equals(r.message,"someMethod cannot yield to 'success' since it was not yet invoked.")}},"pass additional arguments":function(){var e=sinon.spy(),t=sinon.spy(),n=[],r={},i={name1:"value1",name2:"value2"};e({test:t}),e.yieldToOn("test",i,"abc",123,n,r),assert(t.calledWith("abc",123,n,r)),assert(t.calledOn(i))}}})})();