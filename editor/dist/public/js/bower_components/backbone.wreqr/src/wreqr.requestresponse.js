Wreqr.RequestResponse=function(e){return e.Handlers.extend({request:function(){var e=arguments[0],t=Array.prototype.slice.call(arguments,1);if(this.hasHandler(e))return this.getHandler(e).apply(this,t)}})}(Wreqr);