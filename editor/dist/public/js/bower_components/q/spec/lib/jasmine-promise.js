jasmine.Block.prototype.execute=function(e){var t=this.spec;try{var n=this.func.call(t,e);n&&typeof n.then=="function"?Q.timeout(n,500).then(function(){e()},function(n){t.fail(n),e()}):this.func.length===0&&e()}catch(r){t.fail(r),e()}},describe("jasmine-promise",function(){it("passes if the deferred resolves immediately",function(){var e=Q.defer();return e.resolve(),e.promise}),it("passes if the deferred resolves after a short delay",function(){var e=Q.defer();return setTimeout(function(){e.resolve()},100),e.promise}),it("lets specs that return nothing pass",function(){}),it("lets specs that return non-promises pass",function(){return{"some object":"with values"}}),it("works ok with specs that return crappy non-Q promises",function(){return{then:function(e){e()}}}),xdescribe("failure cases (expected to fail)",function(){it("fails if the deferred is rejected",function(){var e=Q.defer();return e.reject(),e.promise}),it("fails if the deferred takes too long to resolve",function(){var e=Q.defer();return setTimeout(function(){e.resolve()},5e3),e.promise}),it("fails if a returned crappy non-Q promise is rejected",function(){return{then:function(e,t){t()}}}),it("fails if a returned crappy promise is never resolved",function(){return{then:function(){}}})})});