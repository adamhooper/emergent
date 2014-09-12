define(["./core"],function(e){var t=window.document.documentElement,n,r=t.matches||t.webkitMatchesSelector||t.mozMatchesSelector||t.oMatchesSelector||t.msMatchesSelector,i=function(t,r){if(t===r)return n=!0,0;var i=r.compareDocumentPosition&&t.compareDocumentPosition&&t.compareDocumentPosition(r);if(i)return i&1?t===document||e.contains(document,t)?-1:r===document||e.contains(document,r)?1:0:i&4?-1:1;return t.compareDocumentPosition?-1:1};e.extend({find:function(t,n,r,i){var s,o,u=0;r=r||[],n=n||document;if(!t||typeof t!="string")return r;if((o=n.nodeType)!==1&&o!==9)return[];if(i)while(s=i[u++])e.find.matchesSelector(s,t)&&r.push(s);else e.merge(r,n.querySelectorAll(t));return r},unique:function(e){var t,r=[],s=0,o=0;n=!1,e.sort(i);if(n){while(t=e[s++])t===e[s]&&(o=r.push(s));while(o--)e.splice(r[o],1)}return e},text:function(t){var n,r="",i=0,s=t.nodeType;if(!s)while(n=t[i++])r+=e.text(n);else{if(s===1||s===9||s===11)return t.textContent;if(s===3||s===4)return t.nodeValue}return r},contains:function(e,t){var n=e.nodeType===9?e.documentElement:e,r=t&&t.parentNode;return e===r||!!r&&r.nodeType===1&&!!n.contains(r)},isXMLDoc:function(e){return(e.ownerDocument||e).documentElement.nodeName!=="HTML"},expr:{attrHandle:{},match:{bool:/^(?:checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped)$/i,needsContext:/^[\x20\t\r\n\f]*[>+~]/}}}),e.extend(e.find,{matches:function(t,n){return e.find(t,null,null,n)},matchesSelector:function(e,t){return r.call(e,t)},attr:function(e,t){return e.getAttribute(t)}})});