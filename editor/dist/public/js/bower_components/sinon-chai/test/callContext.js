(function(){var e;e=require("sinon"),describe("Call context",function(){var t,n,r;return n=null,r=null,t=null,beforeEach(function(){return n=e.spy(),r={},t={}}),describe("calledOn",function(){return it("should throw an assertion error if the spy is never called",function(){return expect(function(){return n.should.have.been.calledOn(r)}).to["throw"](AssertionError)}),it("should throw an assertion error if the spy is called without a context",function(){return n(),expect(function(){return n.should.have.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.getCall(0).should.have.been.calledOn(r)}).to["throw"](AssertionError)}),it("should throw an assertion error if the spy is called on the wrong context",function(){return n.call(t),expect(function(){return n.should.have.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.getCall(0).should.have.been.calledOn(r)}).to["throw"](AssertionError)}),it("should not throw if the spy is called on the specified context",function(){return n.call(r),expect(function(){return n.should.have.been.calledOn(r)}).to.not["throw"](),expect(function(){return n.getCall(0).should.have.been.calledOn(r)}).to.not["throw"]()}),it("should not throw if the spy is called on another context and also the specified context",function(){return n.call(t),n.call(r),expect(function(){return n.should.have.been.calledOn(r)}).to.not["throw"](),expect(function(){return n.getCall(1).should.have.been.calledOn(r)}).to.not["throw"]()})}),describe("always calledOn",function(){return it("should throw an assertion error if the spy is never called",function(){return expect(function(){return n.should.always.have.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.always.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.been.always.calledOn(r)}).to["throw"](AssertionError)}),it("should throw an assertion error if the spy is called without a context",function(){return n(),expect(function(){return n.should.always.have.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.always.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.been.always.calledOn(r)}).to["throw"](AssertionError)}),it("should throw an assertion error if the spy is called on the wrong context",function(){return n.call(t),expect(function(){return n.should.always.have.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.always.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.been.always.calledOn(r)}).to["throw"](AssertionError)}),it("should not throw if the spy is called on the specified context",function(){return n.call(r),expect(function(){return n.should.always.have.been.calledOn(r)}).to.not["throw"](),expect(function(){return n.should.have.always.been.calledOn(r)}).to.not["throw"](),expect(function(){return n.should.have.been.always.calledOn(r)}).to.not["throw"]()}),it("should throw an assertion error if the spy is called on another context and also the specified context",function(){return n.call(t),n.call(r),expect(function(){return n.should.always.have.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.always.been.calledOn(r)}).to["throw"](AssertionError),expect(function(){return n.should.have.been.always.calledOn(r)}).to["throw"](AssertionError)})})})}).call(this);