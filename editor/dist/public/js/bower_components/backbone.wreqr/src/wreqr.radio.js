Wreqr.radio=function(e){var t=function(){this._channels={},this.vent={},this.commands={},this.reqres={},this._proxyMethods()};_.extend(t.prototype,{channel:function(e){if(!e)throw new Error("Channel must receive a name");return this._getChannel(e)},_getChannel:function(t){var n=this._channels[t];return n||(n=new e.Channel(t),this._channels[t]=n),n},_proxyMethods:function(){_.each(["vent","commands","reqres"],function(e){_.each(n[e],function(t){this[e][t]=r(this,e,t)},this)},this)}});var n={vent:["on","off","trigger","once","stopListening","listenTo","listenToOnce"],commands:["execute","setHandler","setHandlers","removeHandler","removeAllHandlers"],reqres:["request","setHandler","setHandlers","removeHandler","removeAllHandlers"]},r=function(e,t,n){return function(r){var i=e._getChannel(r)[t],s=Array.prototype.slice.call(arguments,1);return i[n].apply(i,s)}};return new t}(Wreqr);