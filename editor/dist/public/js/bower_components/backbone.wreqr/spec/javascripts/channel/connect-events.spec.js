describe("Executing `connectEvents` with a hash as the first argument",function(){var e,t="one",n="two",r,i,s,o,u;beforeEach(function(){r=function(){},i=function(){},e=Wreqr.radio.channel("test"),u={},u[n]=r,u[t]=i,o=e.connectEvents(u),s=e.vent._events||{}}),afterEach(function(){e.reset()}),it("should attach the listeners to the Channel",function(){expect(_.keys(s)).toEqual([n,t])}),it("should return the Channel",function(){expect(o).toBe(e)})});