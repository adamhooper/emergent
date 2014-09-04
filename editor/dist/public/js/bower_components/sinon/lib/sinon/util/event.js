/**
 * Minimal Event interface implementation
 *
 * Original implementation by Sven Fuchs: https://gist.github.com/995028
 * Modifications and tests by Christian Johansen.
 *
 * @author Sven Fuchs (svenfuchs@artweb-design.de)
 * @author Christian Johansen (christian@cjohansen.no)
 * @license BSD
 *
 * Copyright (c) 2011 Sven Fuchs, Christian Johansen
 */

typeof sinon=="undefined"&&(this.sinon={}),function(){var e=[].push;sinon.Event=function(t,n,r,i){this.initEvent(t,n,r,i)},sinon.Event.prototype={initEvent:function(e,t,n,r){this.type=e,this.bubbles=t,this.cancelable=n,this.target=r},stopPropagation:function(){},preventDefault:function(){this.defaultPrevented=!0}},sinon.ProgressEvent=function(t,n,r){this.initEvent(t,!1,!1,r),this.loaded=n.loaded||null,this.total=n.total||null},sinon.ProgressEvent.prototype=new sinon.Event,sinon.ProgressEvent.prototype.constructor=sinon.ProgressEvent,sinon.CustomEvent=function(t,n,r){this.initEvent(t,!1,!1,r),this.detail=n.detail||null},sinon.CustomEvent.prototype=new sinon.Event,sinon.CustomEvent.prototype.constructor=sinon.CustomEvent,sinon.EventTarget={addEventListener:function(n,r){this.eventListeners=this.eventListeners||{},this.eventListeners[n]=this.eventListeners[n]||[],e.call(this.eventListeners[n],r)},removeEventListener:function(t,n){var r=this.eventListeners&&this.eventListeners[t]||[];for(var i=0,s=r.length;i<s;++i)if(r[i]==n)return r.splice(i,1)},dispatchEvent:function(t){var n=t.type,r=this.eventListeners&&this.eventListeners[n]||[];for(var i=0;i<r.length;i++)typeof r[i]=="function"?r[i].call(this,t):r[i].handleEvent(t);return!!t.defaultPrevented}}}();