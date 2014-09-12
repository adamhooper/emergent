(function(){var e;e=require("sinon"),describe("Calling with new",function(){var t;return t=null,beforeEach(function(){return t=e.spy()}),describe("calledWithNew",function(){return it("should throw an assertion error if the spy is never called",function(){return expect(function(){return t.should.have.been.calledWithNew}).to["throw"](AssertionError)}),it("should throw an assertion error if the spy is called without `new`",function(){return t(),expect(function(){return t.should.have.been.calledWithNew}).to["throw"](AssertionError),expect(function(){return t.getCall(0).should.have.been.calledWithNew}).to["throw"](AssertionError)}),it("should not throw if the spy is called with `new`",function(){return new t,expect(function(){return t.should.have.been.calledWithNew}).to.not["throw"](),expect(function(){return t.getCall(0).should.have.been.calledWithNew}).to.not["throw"]()}),it("should not throw if the spy is called with `new` and also without `new`",function(){return t(),new t,expect(function(){return t.should.have.been.calledWithNew}).to.not["throw"](),expect(function(){return t.getCall(1).should.have.been.calledWithNew}).to.not["throw"]()})}),describe("always calledWithNew",function(){return it("should throw an assertion error if the spy is never called",function(){return expect(function(){return t.should.always.have.been.calledWithNew}).to["throw"](AssertionError),expect(function(){return t.should.have.always.been.calledWithNew}).to["throw"](AssertionError),expect(function(){return t.should.have.been.always.calledWithNew}).to["throw"](AssertionError)}),it("should throw an assertion error if the spy is called without `new`",function(){return t(),expect(function(){return t.should.always.have.been.calledWithNew}).to["throw"](AssertionError),expect(function(){return t.should.have.always.been.calledWithNew}).to["throw"](AssertionError),expect(function(){return t.should.have.been.always.calledWithNew}).to["throw"](AssertionError)}),it("should not throw if the spy is called with `new`",function(){return new t,expect(function(){return t.should.always.have.been.calledWithNew}).to.not["throw"](),expect(function(){return t.should.have.always.been.calledWithNew}).to.not["throw"](),expect(function(){return t.should.have.been.always.calledWithNew}).to.not["throw"]()}),it("should throw an assertion error if the spy is called with `new` and also without `new`",function(){return t(),new t,expect(function(){return t.should.always.have.been.calledWithNew}).to["throw"](AssertionError),expect(function(){return t.should.have.always.been.calledWithNew}).to["throw"](AssertionError),expect(function(){return t.should.have.been.always.calledWithNew}).to["throw"](AssertionError)})})})}).call(this);