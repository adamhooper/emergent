/**
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2010-2012 Christian Johansen
 */

if(typeof require=="function"&&typeof module=="object"){var buster=require("../../runner"),sinon=require("../../../lib/sinon");sinon.extend(sinon,require("../../../lib/sinon/util/fake_timers"))}var globalDate=Date;buster.testCase("sinon.clock",{setUp:function(){this.global=typeof global!="undefined"?global:window},setTimeout:{setUp:function(){this.clock=sinon.clock.create(),sinon.clock.evalCalled=!1},tearDown:function(){delete sinon.clock.evalCalled},"throws if no arguments":function(){var e=this.clock;assert.exception(function(){e.setTimeout()})},"returns numeric id or object with numeric id":function(){var e=this.clock.setTimeout("");typeof e=="object"?assert.isNumber(e.id):assert.isNumber(e)},"returns unique id":function(){var e=this.clock.setTimeout(""),t=this.clock.setTimeout("");refute.equals(t,e)},"sets timers on instance":function(){var e=sinon.clock.create(),t=sinon.clock.create(),n=[sinon.stub.create(),sinon.stub.create()];e.setTimeout(n[0],100),t.setTimeout(n[1],100),t.tick(200),assert.isFalse(n[0].called),assert(n[1].called)},"evals non-function callbacks":function(){this.clock.setTimeout("sinon.clock.evalCalled = true",10),this.clock.tick(10),assert(sinon.clock.evalCalled)},"passes setTimeout parameters":function(){var e=sinon.clock.create(),t=sinon.stub.create();e.setTimeout(t,2,"the first","the second"),e.tick(3),assert.isTrue(t.calledWithExactly("the first","the second"))},"calls correct timeout on recursive tick":function(){var e=sinon.clock.create(),t=sinon.stub.create(),n=function(){e.tick(100)};e.setTimeout(n,50),e.setTimeout(t,100),e.tick(50),assert(t.called)}},setImmediate:{setUp:function(){this.clock=sinon.clock.create()},"returns numeric id or object with numeric id":function(){var e=this.clock.setImmediate(function(){});typeof e=="object"?assert.isNumber(e.id):assert.isNumber(e)},"calls the given callback immediately":function(){var e=sinon.stub.create();this.clock.setImmediate(e),this.clock.tick(0),assert(e.called)},"throws if no arguments":function(){var e=this.clock;assert.exception(function(){e.setImmediate()})},"manages separate timers per clock instance":function(){var e=sinon.clock.create(),t=sinon.clock.create(),n=[sinon.stub.create(),sinon.stub.create()];e.setImmediate(n[0]),t.setImmediate(n[1]),t.tick(0),assert.isFalse(n[0].called),assert(n[1].called)},"passes extra parameters through to the callback":function(){var e=sinon.stub.create();this.clock.setImmediate(e,"value1",2),this.clock.tick(1),assert(e.calledWithExactly("value1",2))}},clearImmediate:{setUp:function(){this.clock=sinon.clock.create()},"removes immediate callbacks":function(){var e=sinon.stub.create(),t=this.clock.setImmediate(e);this.clock.clearImmediate(t),this.clock.tick(1),assert.isFalse(e.called)}},tick:{setUp:function(){this.clock=sinon.useFakeTimers(0)},tearDown:function(){this.clock.restore()},"triggers immediately without specified delay":function(){var e=sinon.stub.create();this.clock.setTimeout(e),this.clock.tick(0),assert(e.called)},"does not trigger without sufficient delay":function(){var e=sinon.stub.create();this.clock.setTimeout(e,100),this.clock.tick(10),assert.isFalse(e.called)},"triggers after sufficient delay":function(){var e=sinon.stub.create();this.clock.setTimeout(e,100),this.clock.tick(100),assert(e.called)},"triggers simultaneous timers":function(){var e=[sinon.spy(),sinon.spy()];this.clock.setTimeout(e[0],100),this.clock.setTimeout(e[1],100),this.clock.tick(100),assert(e[0].called),assert(e[1].called)},"triggers multiple simultaneous timers":function(){var e=[sinon.spy(),sinon.spy(),sinon.spy(),sinon.spy()];this.clock.setTimeout(e[0],100),this.clock.setTimeout(e[1],100),this.clock.setTimeout(e[2],99),this.clock.setTimeout(e[3],100),this.clock.tick(100),assert(e[0].called),assert(e[1].called),assert(e[2].called),assert(e[3].called)},"triggers multiple simultaneous timers with zero callAt":function(){var e=this,t=[sinon.spy(function(){e.clock.setTimeout(t[1],0)}),sinon.spy(),sinon.spy()];this.clock.setTimeout(t[0],0),this.clock.setTimeout(t[2],10),this.clock.tick(10),assert(t[0].called),assert(t[1].called),assert(t[2].called)},"waits after setTimeout was called":function(){this.clock.tick(100);var e=sinon.stub.create();this.clock.setTimeout(e,150),this.clock.tick(50),assert.isFalse(e.called),this.clock.tick(100),assert(e.called)},"mini integration test":function(){var e=[sinon.stub.create(),sinon.stub.create(),sinon.stub.create()];this.clock.setTimeout(e[0],100),this.clock.setTimeout(e[1],120),this.clock.tick(10),this.clock.tick(89),assert.isFalse(e[0].called),assert.isFalse(e[1].called),this.clock.setTimeout(e[2],20),this.clock.tick(1),assert(e[0].called),assert.isFalse(e[1].called),assert.isFalse(e[2].called),this.clock.tick(19),assert.isFalse(e[1].called),assert(e[2].called),this.clock.tick(1),assert(e[1].called)},"triggers even when some throw":function(){var e=this.clock,t=[sinon.stub.create().throws(),sinon.stub.create()];e.setTimeout(t[0],100),e.setTimeout(t[1],120),assert.exception(function(){e.tick(120)}),assert(t[0].called),assert(t[1].called)},"calls function with global object or null (strict mode) as this":function(){var e=this.clock,t=sinon.stub.create().throws();e.setTimeout(t,100),assert.exception(function(){e.tick(100)}),assert(t.calledOn(this.global)||t.calledOn(null))},"triggers in the order scheduled":function(){var e=[sinon.spy.create(),sinon.spy.create()];this.clock.setTimeout(e[0],13),this.clock.setTimeout(e[1],11),this.clock.tick(15),assert(e[1].calledBefore(e[0]))},"creates updated Date while ticking":function(){var e=sinon.spy.create();this.clock.setInterval(function(){e((new Date).getTime())},10),this.clock.tick(100),assert.equals(e.callCount,10),assert(e.calledWith(10)),assert(e.calledWith(20)),assert(e.calledWith(30)),assert(e.calledWith(40)),assert(e.calledWith(50)),assert(e.calledWith(60)),assert(e.calledWith(70)),assert(e.calledWith(80)),assert(e.calledWith(90)),assert(e.calledWith(100))},"fires timer in intervals of 13":function(){var e=sinon.spy.create();this.clock.setInterval(e,13),this.clock.tick(500),assert.equals(e.callCount,38)},"fires timers in correct order":function(){var e=sinon.spy.create(),t=sinon.spy.create();this.clock.setInterval(function(){e((new Date).getTime())},13),this.clock.setInterval(function(){t((new Date).getTime())},10),this.clock.tick(500),assert.equals(e.callCount,38),assert.equals(t.callCount,50),assert(e.calledWith(416)),assert(t.calledWith(320)),assert(t.getCall(0).calledBefore(e.getCall(0))),assert(t.getCall(4).calledBefore(e.getCall(3)))},"triggers timeouts and intervals in the order scheduled":function(){var e=[sinon.spy.create(),sinon.spy.create()];this.clock.setInterval(e[0],10),this.clock.setTimeout(e[1],50),this.clock.tick(100),assert(e[0].calledBefore(e[1])),assert.equals(e[0].callCount,10),assert.equals(e[1].callCount,1)},"does not fire canceled intervals":function(){var e,t=sinon.spy(function(){t.callCount==3&&clearTimeout(e)});e=this.clock.setInterval(t,10),this.clock.tick(100),assert.equals(t.callCount,3)},"passes 6 seconds":function(){var e=sinon.spy.create();this.clock.setInterval(e,4e3),this.clock.tick("08"),assert.equals(e.callCount,2)},"passes 1 minute":function(){var e=sinon.spy.create();this.clock.setInterval(e,6e3),this.clock.tick("01:00"),assert.equals(e.callCount,10)},"passes 2 hours, 34 minutes and 12 seconds":function(){var e=sinon.spy.create();this.clock.setInterval(e,1e4),this.clock.tick("02:34:10"),assert.equals(e.callCount,925)},"throws for invalid format":function(){var e=sinon.spy.create();this.clock.setInterval(e,1e4);var t=this;assert.exception(function(){t.clock.tick("12:02:34:10")}),assert.equals(e.callCount,0)},"throws for invalid minutes":function(){var e=sinon.spy.create();this.clock.setInterval(e,1e4);var t=this;assert.exception(function(){t.clock.tick("67:10")}),assert.equals(e.callCount,0)},"throws for negative minutes":function(){var e=sinon.spy.create();this.clock.setInterval(e,1e4);var t=this;assert.exception(function(){t.clock.tick("-7:10")}),assert.equals(e.callCount,0)},"treats missing argument as 0":function(){this.clock.tick(),assert.equals(this.clock.now,0)},"fires nested setTimeout calls properly":function(){var e=0,t=this.clock,n=function(){++e,t.setTimeout(function(){n()},100)};n(),t.tick(1e3),assert.equals(e,11)},"does not silently catch exceptions":function(){var e=this.clock;e.setTimeout(function(){throw new Exception("oh no!")},1e3),assert.exception(function(){e.tick(1e3)})},"returns the current now value":function(){var e=this.clock,t=e.tick(200);assert.equals(e.now,t)}},clearTimeout:{setUp:function(){this.clock=sinon.clock.create()},"removes timeout":function(){var e=sinon.stub.create(),t=this.clock.setTimeout(e,50);this.clock.clearTimeout(t),this.clock.tick(50),assert.isFalse(e.called)}},reset:{setUp:function(){this.clock=sinon.clock.create()},"empties timeouts queue":function(){var e=sinon.stub.create();this.clock.setTimeout(e),this.clock.reset(),this.clock.tick(0),assert.isFalse(e.called)}},setInterval:{setUp:function(){this.clock=sinon.clock.create()},"throws if no arguments":function(){var e=this.clock;assert.exception(function(){e.setInterval()})},"returns numeric id or object with numeric id":function(){var e=this.clock.setInterval("");typeof e=="object"?assert.isNumber(e.id):assert.isNumber(e)},"returns unique id":function(){var e=this.clock.setInterval(""),t=this.clock.setInterval("");refute.equals(t,e)},"schedules recurring timeout":function(){var e=sinon.stub.create();this.clock.setInterval(e,10),this.clock.tick(99),assert.equals(e.callCount,9)},"does not schedule recurring timeout when cleared":function(){var e=this.clock,t,n=sinon.spy.create(function(){n.callCount==3&&e.clearInterval(t)});t=this.clock.setInterval(n,10),this.clock.tick(100),assert.equals(n.callCount,3)},"passes setTimeout parameters":function(){var e=sinon.clock.create(),t=sinon.stub.create();e.setInterval(t,2,"the first","the second"),e.tick(3),assert.isTrue(t.calledWithExactly("the first","the second"))}},date:{setUp:function(){this.now=(new globalDate).getTime()-3e3,this.clock=sinon.clock.create(this.now),this.Date=this.global.Date},tearDown:function(){this.global.Date=this.Date},"provides date constructor":function(){assert.isFunction(this.clock.Date)},"creates real Date objects":function(){var e=new this.clock.Date;assert(Date.prototype.isPrototypeOf(e))},"creates real Date objects when called as function":function(){var e=this.clock.Date();assert(Date.prototype.isPrototypeOf(e))},"creates real Date objects when Date constructor is gone":function(){var e=new Date;Date=function(){},this.global.Date=function(){};var t=new this.clock.Date;assert.same(t.constructor.prototype,e.constructor.prototype)},"creates Date objects representing clock time":function(){var e=new this.clock.Date;assert.equals(e.getTime(),(new Date(this.now)).getTime())},"returns Date object representing clock time":function(){var e=this.clock.Date();assert.equals(e.getTime(),(new Date(this.now)).getTime())},"listens to ticking clock":function(){var e=new this.clock.Date;this.clock.tick(3);var t=new this.clock.Date;assert.equals(t.getTime()-e.getTime(),3)},"creates regular date when passing timestamp":function(){var e=new Date,t=new this.clock.Date(e.getTime());assert.equals(t.getTime(),e.getTime())},"returns regular date when calling with timestamp":function(){var e=new Date,t=this.clock.Date(e.getTime());assert.equals(t.getTime(),e.getTime())},"creates regular date when passing year, month":function(){var e=new Date(2010,4),t=new this.clock.Date(2010,4);assert.equals(t.getTime(),e.getTime())},"returns regular date when calling with year, month":function(){var e=new Date(2010,4),t=this.clock.Date(2010,4);assert.equals(t.getTime(),e.getTime())},"creates regular date when passing y, m, d":function(){var e=new Date(2010,4,2),t=new this.clock.Date(2010,4,2);assert.equals(t.getTime(),e.getTime())},"returns regular date when calling with y, m, d":function(){var e=new Date(2010,4,2),t=this.clock.Date(2010,4,2);assert.equals(t.getTime(),e.getTime())},"creates regular date when passing y, m, d, h":function(){var e=new Date(2010,4,2,12),t=new this.clock.Date(2010,4,2,12);assert.equals(t.getTime(),e.getTime())},"returns regular date when calling with y, m, d, h":function(){var e=new Date(2010,4,2,12),t=this.clock.Date(2010,4,2,12);assert.equals(t.getTime(),e.getTime())},"creates regular date when passing y, m, d, h, m":function(){var e=new Date(2010,4,2,12,42),t=new this.clock.Date(2010,4,2,12,42);assert.equals(t.getTime(),e.getTime())},"returns regular date when calling with y, m, d, h, m":function(){var e=new Date(2010,4,2,12,42),t=this.clock.Date(2010,4,2,12,42);assert.equals(t.getTime(),e.getTime())},"creates regular date when passing y, m, d, h, m, s":function(){var e=new Date(2010,4,2,12,42,53),t=new this.clock.Date(2010,4,2,12,42,53);assert.equals(t.getTime(),e.getTime())},"returns regular date when calling with y, m, d, h, m, s":function(){var e=new Date(2010,4,2,12,42,53),t=this.clock.Date(2010,4,2,12,42,53);assert.equals(t.getTime(),e.getTime())},"creates regular date when passing y, m, d, h, m, s, ms":function(){var e=new Date(2010,4,2,12,42,53,498),t=new this.clock.Date(2010,4,2,12,42,53,498);assert.equals(t.getTime(),e.getTime())},"returns regular date when calling with y, m, d, h, m, s, ms":function(){var e=new Date(2010,4,2,12,42,53,498),t=this.clock.Date(2010,4,2,12,42,53,498);assert.equals(t.getTime(),e.getTime())},"mirrors native Date.prototype":function(){assert.same(this.clock.Date.prototype,Date.prototype)},"supports now method if present":function(){assert.same(typeof this.clock.Date.now,typeof Date.now)},now:{requiresSupportFor:{"Date.now":!!Date.now},"returns clock.now":function(){assert.equals(this.clock.Date.now(),this.now)}},"unsupported now":{requiresSupportFor:{"No Date.now implementation":!Date.now},"is undefined":function(){refute.defined(this.clock.Date.now)}},"mirrors parse method":function(){assert.same(this.clock.Date.parse,Date.parse)},"mirrors UTC method":function(){assert.same(this.clock.Date.UTC,Date.UTC)},"mirrors toUTCString method":function(){assert.same(this.clock.Date.prototype.toUTCString,Date.prototype.toUTCString)},toSource:{requiresSupportFor:{"Date.toSource":!!Date.toSource},"is mirrored":function(){assert.same(this.clock.Date.toSource(),Date.toSource())}},"unsupported toSource":{requiresSupportFor:{"No Date.toSource implementation":!Date.toSource},"is undefined":function(){refute.defined(this.clock.Date.toSource)}},"mirrors toString":function(){assert.same(this.clock.Date.toString(),Date.toString())}},stubTimers:{setUp:function(){this.dateNow=this.global.Date.now},tearDown:function(){this.clock&&this.clock.restore(),clearTimeout(this.timer),typeof this.dateNow=="undefined"?delete this.global.Date.now:this.global.Date.now=this.dateNow},"returns clock object":function(){this.clock=sinon.useFakeTimers(),assert.isObject(this.clock),assert.isFunction(this.clock.tick)},"has clock property":function(){this.clock=sinon.useFakeTimers(),assert.same(setTimeout.clock,this.clock),assert.same(clearTimeout.clock,this.clock),assert.same(setInterval.clock,this.clock),assert.same(clearInterval.clock,this.clock),assert.same(Date.clock,this.clock)},"sets initial timestamp":function(){this.clock=sinon.useFakeTimers(1400),assert.equals(this.clock.now,1400)},"replaces global setTimeout":function(){this.clock=sinon.useFakeTimers();var e=sinon.stub.create();setTimeout(e,1e3),this.clock.tick(1e3),assert(e.called)},"global fake setTimeout should return id":function(){this.clock=sinon.useFakeTimers();var e=sinon.stub.create(),t=setTimeout(e,1e3);typeof setTimeout(function(){},0)=="object"?(assert.isNumber(t.id),assert.isFunction(t.ref),assert.isFunction(t.unref)):assert.isNumber(t)},"replaces global clearTimeout":function(){this.clock=sinon.useFakeTimers();var e=sinon.stub.create();clearTimeout(setTimeout(e,1e3)),this.clock.tick(1e3),assert.isFalse(e.called)},"restores global setTimeout":function(){this.clock=sinon.useFakeTimers();var e=sinon.stub.create();this.clock.restore(),this.timer=setTimeout(e,1e3),this.clock.tick(1e3),assert.isFalse(e.called),assert.same(setTimeout,sinon.timers.setTimeout)},"restores global clearTimeout":function(){this.clock=sinon.useFakeTimers(),sinon.stub.create(),this.clock.restore(),assert.same(clearTimeout,sinon.timers.clearTimeout)},"replaces global setInterval":function(){this.clock=sinon.useFakeTimers();var e=sinon.stub.create();setInterval(e,500),this.clock.tick(1e3),assert(e.calledTwice)},"replaces global clearInterval":function(){this.clock=sinon.useFakeTimers();var e=sinon.stub.create();clearInterval(setInterval(e,500)),this.clock.tick(1e3),assert.isFalse(e.called)},"restores global setInterval":function(){this.clock=sinon.useFakeTimers();var e=sinon.stub.create();this.clock.restore(),this.timer=setInterval(e,1e3),this.clock.tick(1e3),assert.isFalse(e.called),assert.same(setInterval,sinon.timers.setInterval)},"restores global clearInterval":function(){this.clock=sinon.useFakeTimers(),sinon.stub.create(),this.clock.restore(),assert.same(clearInterval,sinon.timers.clearInterval)},"deletes global property on restore if it was inherited onto the global object":function(){delete this.global.tick,this.global.__proto__.tick=function(){},this.clock=sinon.useFakeTimers("tick"),assert.isTrue(this.global.hasOwnProperty("tick")),this.clock.restore(),assert.isFalse(this.global.hasOwnProperty("tick")),delete this.global.__proto__.tick},"restores global property on restore if it is present on the global object itself":function(){this.global.tick=function(){},this.clock=sinon.useFakeTimers("tick"),assert.isTrue(this.global.hasOwnProperty("tick")),this.clock.restore(),assert.isTrue(this.global.hasOwnProperty("tick")),delete this.global.tick},"fakes Date constructor":function(){this.clock=sinon.useFakeTimers(0);var e=new Date;refute.same(Date,sinon.timers.Date),assert.equals(e.getTime(),0)},"fake Date constructor should mirror Date's properties":function(){this.clock=sinon.useFakeTimers(0),assert(!!Date.parse),assert(!!Date.UTC)},"decide on Date.now support at call-time when supported":function(){this.global.Date.now=function(){},this.clock=sinon.useFakeTimers(0),assert.equals(typeof Date.now,"function")},"decide on Date.now support at call-time when unsupported":function(){this.global.Date.now=null,this.clock=sinon.useFakeTimers(0),refute.defined(Date.now)},"mirrors custom Date properties":function(){var e=function(){};this.global.Date.format=e,sinon.useFakeTimers(),assert.equals(Date.format,e)},"restores Date constructor":function(){this.clock=sinon.useFakeTimers(0),this.clock.restore(),assert.same(globalDate,sinon.timers.Date)},"fakes provided methods":function(){this.clock=sinon.useFakeTimers("setTimeout","Date"),refute.same(setTimeout,sinon.timers.setTimeout),refute.same(Date,sinon.timers.Date)},"resets faked methods":function(){this.clock=sinon.useFakeTimers("setTimeout","Date"),this.clock.restore(),assert.same(setTimeout,sinon.timers.setTimeout),assert.same(Date,sinon.timers.Date)},"does not fake methods not provided":function(){this.clock=sinon.useFakeTimers("setTimeout","Date"),assert.same(clearTimeout,sinon.timers.clearTimeout),assert.same(setInterval,sinon.timers.setInterval),assert.same(clearInterval,sinon.timers.clearInterval)},"does not be able to use date object for now":function(){assert.exception(function(){sinon.useFakeTimers(new Date(2011,9,1))})}}});