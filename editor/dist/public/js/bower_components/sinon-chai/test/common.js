global.chai=require("chai"),global.should=require("chai").should(),global.expect=require("chai").expect,global.AssertionError=require("chai").AssertionError,global.swallow=function(e){try{e()}catch(t){}};var sinonChai=require("../lib/sinon-chai");chai.use(sinonChai);