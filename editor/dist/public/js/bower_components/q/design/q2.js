var Promise=function(){},isPromise=function(e){return e instanceof Promise},defer=function(){var e=[],t,n=new Promise;return n.then=function(n){e?e.push(n):n(t)},{resolve:function(n){if(e){t=n;for(var r=0,i=e.length;r<i;r++){var s=e[r];s(t)}e=undefined}},promise:n}};