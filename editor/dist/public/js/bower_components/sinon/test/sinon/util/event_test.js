/**
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2011-2012 Christian Johansen
 */

buster.testCase("sinon.EventTarget",{setUp:function(){this.target=sinon.extend({},sinon.EventTarget)},"notifies event listener":function(){var e=sinon.spy();this.target.addEventListener("dummy",e);var t=new sinon.Event("dummy");this.target.dispatchEvent(t),assert(e.calledOnce),assert(e.calledWith(t))},"notifies event listener with target as this":function(){var e=sinon.spy();this.target.addEventListener("dummy",e);var t=new sinon.Event("dummy");this.target.dispatchEvent(t),assert(e.calledOn(this.target))},"notifies all event listeners":function(){var e=[sinon.spy(),sinon.spy()];this.target.addEventListener("dummy",e[0]),this.target.addEventListener("dummy",e[1]);var t=new sinon.Event("dummy");this.target.dispatchEvent(t),assert(e[0].calledOnce),assert(e[0].calledOnce)},"notifies event listener of type listener":function(){var e={handleEvent:sinon.spy()};this.target.addEventListener("dummy",e),this.target.dispatchEvent(new sinon.Event("dummy")),assert(e.handleEvent.calledOnce)},"does not notify listeners of other events":function(){var e=[sinon.spy(),sinon.spy()];this.target.addEventListener("dummy",e[0]),this.target.addEventListener("other",e[1]),this.target.dispatchEvent(new sinon.Event("dummy")),assert.isFalse(e[1].called)},"does not notify unregistered listeners":function(){var e=sinon.spy();this.target.addEventListener("dummy",e),this.target.removeEventListener("dummy",e),this.target.dispatchEvent(new sinon.Event("dummy")),assert.isFalse(e.called)},"notifies existing listeners after removing one":function(){var e=[sinon.spy(),sinon.spy(),sinon.spy()];this.target.addEventListener("dummy",e[0]),this.target.addEventListener("dummy",e[1]),this.target.addEventListener("dummy",e[2]),this.target.removeEventListener("dummy",e[1]),this.target.dispatchEvent(new sinon.Event("dummy")),assert(e[0].calledOnce),assert(e[2].calledOnce)},"returns false when event.preventDefault is not called":function(){this.target.addEventListener("dummy",sinon.spy());var e=new sinon.Event("dummy"),t=this.target.dispatchEvent(e);assert.isFalse(t)},"returns true when event.preventDefault is called":function(){this.target.addEventListener("dummy",function(e){e.preventDefault()});var e=this.target.dispatchEvent(new sinon.Event("dummy"));assert.isTrue(e)},"notifies ProgressEvent listener with progress data ":function(){var e=sinon.spy();this.target.addEventListener("dummyProgress",e);var t=new sinon.ProgressEvent("dummyProgress",{loaded:50,total:120});this.target.dispatchEvent(t),assert(e.calledOnce),assert(e.calledWith(t))},"notifies CustomEvent listener with custom data":function(){var e=sinon.spy();this.target.addEventListener("dummyCustom",e);var t=new sinon.CustomEvent("dummyCustom",{detail:"hola"});this.target.dispatchEvent(t),assert(e.calledOnce),assert(e.calledWith(t))}});