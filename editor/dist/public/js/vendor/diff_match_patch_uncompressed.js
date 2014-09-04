/**
 * Diff Match and Patch
 *
 * Copyright 2006 Google Inc.
 * http://code.google.com/p/google-diff-match-patch/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

function diff_match_patch(){this.Diff_Timeout=1,this.Diff_EditCost=4,this.Match_Threshold=.5,this.Match_Distance=1e3,this.Patch_DeleteThreshold=.5,this.Patch_Margin=4,this.Match_MaxBits=32}var DIFF_DELETE=-1,DIFF_INSERT=1,DIFF_EQUAL=0;diff_match_patch.Diff,diff_match_patch.prototype.diff_main=function(e,t,n,r){typeof r=="undefined"&&(this.Diff_Timeout<=0?r=Number.MAX_VALUE:r=(new Date).getTime()+this.Diff_Timeout*1e3);var i=r;if(e==null||t==null)throw new Error("Null input. (diff_main)");if(e==t)return e?[[DIFF_EQUAL,e]]:[];typeof n=="undefined"&&(n=!0);var s=n,o=this.diff_commonPrefix(e,t),u=e.substring(0,o);e=e.substring(o),t=t.substring(o),o=this.diff_commonSuffix(e,t);var a=e.substring(e.length-o);e=e.substring(0,e.length-o),t=t.substring(0,t.length-o);var f=this.diff_compute_(e,t,s,i);return u&&f.unshift([DIFF_EQUAL,u]),a&&f.push([DIFF_EQUAL,a]),this.diff_cleanupMerge(f),f},diff_match_patch.prototype.diff_compute_=function(e,t,n,r){var i;if(!e)return[[DIFF_INSERT,t]];if(!t)return[[DIFF_DELETE,e]];var s=e.length>t.length?e:t,o=e.length>t.length?t:e,u=s.indexOf(o);if(u!=-1)return i=[[DIFF_INSERT,s.substring(0,u)],[DIFF_EQUAL,o],[DIFF_INSERT,s.substring(u+o.length)]],e.length>t.length&&(i[0][0]=i[2][0]=DIFF_DELETE),i;if(o.length==1)return[[DIFF_DELETE,e],[DIFF_INSERT,t]];var a=this.diff_halfMatch_(e,t);if(a){var f=a[0],l=a[1],c=a[2],h=a[3],p=a[4],d=this.diff_main(f,c,n,r),v=this.diff_main(l,h,n,r);return d.concat([[DIFF_EQUAL,p]],v)}return n&&e.length>100&&t.length>100?this.diff_lineMode_(e,t,r):this.diff_bisect_(e,t,r)},diff_match_patch.prototype.diff_lineMode_=function(e,t,n){var r=this.diff_linesToChars_(e,t);e=r.chars1,t=r.chars2;var i=r.lineArray,s=this.diff_main(e,t,!1,n);this.diff_charsToLines_(s,i),this.diff_cleanupSemantic(s),s.push([DIFF_EQUAL,""]);var o=0,u=0,a=0,f="",l="";while(o<s.length){switch(s[o][0]){case DIFF_INSERT:a++,l+=s[o][1];break;case DIFF_DELETE:u++,f+=s[o][1];break;case DIFF_EQUAL:if(u>=1&&a>=1){s.splice(o-u-a,u+a),o=o-u-a;var r=this.diff_main(f,l,!1,n);for(var c=r.length-1;c>=0;c--)s.splice(o,0,r[c]);o+=r.length}a=0,u=0,f="",l=""}o++}return s.pop(),s},diff_match_patch.prototype.diff_bisect_=function(e,t,n){var r=e.length,i=t.length,s=Math.ceil((r+i)/2),o=s,u=2*s,a=new Array(u),f=new Array(u);for(var l=0;l<u;l++)a[l]=-1,f[l]=-1;a[o+1]=0,f[o+1]=0;var c=r-i,h=c%2!=0,p=0,d=0,v=0,m=0;for(var g=0;g<s;g++){if((new Date).getTime()>n)break;for(var y=-g+p;y<=g-d;y+=2){var b=o+y,w;y==-g||y!=g&&a[b-1]<a[b+1]?w=a[b+1]:w=a[b-1]+1;var E=w-y;while(w<r&&E<i&&e.charAt(w)==t.charAt(E))w++,E++;a[b]=w;if(w>r)d+=2;else if(E>i)p+=2;else if(h){var S=o+c-y;if(S>=0&&S<u&&f[S]!=-1){var x=r-f[S];if(w>=x)return this.diff_bisectSplit_(e,t,w,E,n)}}}for(var T=-g+v;T<=g-m;T+=2){var S=o+T,x;T==-g||T!=g&&f[S-1]<f[S+1]?x=f[S+1]:x=f[S-1]+1;var N=x-T;while(x<r&&N<i&&e.charAt(r-x-1)==t.charAt(i-N-1))x++,N++;f[S]=x;if(x>r)m+=2;else if(N>i)v+=2;else if(!h){var b=o+c-T;if(b>=0&&b<u&&a[b]!=-1){var w=a[b],E=o+w-b;x=r-x;if(w>=x)return this.diff_bisectSplit_(e,t,w,E,n)}}}}return[[DIFF_DELETE,e],[DIFF_INSERT,t]]},diff_match_patch.prototype.diff_bisectSplit_=function(e,t,n,r,i){var s=e.substring(0,n),o=t.substring(0,r),u=e.substring(n),a=t.substring(r),f=this.diff_main(s,o,!1,i),l=this.diff_main(u,a,!1,i);return f.concat(l)},diff_match_patch.prototype.diff_linesToChars_=function(e,t){function i(e){var t="",i=0,s=-1,o=n.length;while(s<e.length-1){s=e.indexOf("\n",i),s==-1&&(s=e.length-1);var u=e.substring(i,s+1);i=s+1,(r.hasOwnProperty?r.hasOwnProperty(u):r[u]!==undefined)?t+=String.fromCharCode(r[u]):(t+=String.fromCharCode(o),r[u]=o,n[o++]=u)}return t}var n=[],r={};n[0]="";var s=i(e),o=i(t);return{chars1:s,chars2:o,lineArray:n}},diff_match_patch.prototype.diff_charsToLines_=function(e,t){for(var n=0;n<e.length;n++){var r=e[n][1],i=[];for(var s=0;s<r.length;s++)i[s]=t[r.charCodeAt(s)];e[n][1]=i.join("")}},diff_match_patch.prototype.diff_commonPrefix=function(e,t){if(!e||!t||e.charAt(0)!=t.charAt(0))return 0;var n=0,r=Math.min(e.length,t.length),i=r,s=0;while(n<i)e.substring(s,i)==t.substring(s,i)?(n=i,s=n):r=i,i=Math.floor((r-n)/2+n);return i},diff_match_patch.prototype.diff_commonSuffix=function(e,t){if(!e||!t||e.charAt(e.length-1)!=t.charAt(t.length-1))return 0;var n=0,r=Math.min(e.length,t.length),i=r,s=0;while(n<i)e.substring(e.length-i,e.length-s)==t.substring(t.length-i,t.length-s)?(n=i,s=n):r=i,i=Math.floor((r-n)/2+n);return i},diff_match_patch.prototype.diff_commonOverlap_=function(e,t){var n=e.length,r=t.length;if(n==0||r==0)return 0;n>r?e=e.substring(n-r):n<r&&(t=t.substring(0,n));var i=Math.min(n,r);if(e==t)return i;var s=0,o=1;for(;;){var u=e.substring(i-o),a=t.indexOf(u);if(a==-1)return s;o+=a;if(a==0||e.substring(i-o)==t.substring(0,o))s=o,o++}},diff_match_patch.prototype.diff_halfMatch_=function(e,t){function s(e,t,n){var r=e.substring(n,n+Math.floor(e.length/4)),s=-1,o="",u,a,f,l;while((s=t.indexOf(r,s+1))!=-1){var c=i.diff_commonPrefix(e.substring(n),t.substring(s)),h=i.diff_commonSuffix(e.substring(0,n),t.substring(0,s));o.length<h+c&&(o=t.substring(s-h,s)+t.substring(s,s+c),u=e.substring(0,n-h),a=e.substring(n+c),f=t.substring(0,s-h),l=t.substring(s+c))}return o.length*2>=e.length?[u,a,f,l,o]:null}if(this.Diff_Timeout<=0)return null;var n=e.length>t.length?e:t,r=e.length>t.length?t:e;if(n.length<4||r.length*2<n.length)return null;var i=this,o=s(n,r,Math.ceil(n.length/4)),u=s(n,r,Math.ceil(n.length/2)),a;if(!o&&!u)return null;u?o?a=o[4].length>u[4].length?o:u:a=u:a=o;var f,l,c,h;e.length>t.length?(f=a[0],l=a[1],c=a[2],h=a[3]):(c=a[0],h=a[1],f=a[2],l=a[3]);var p=a[4];return[f,l,c,h,p]},diff_match_patch.prototype.diff_cleanupSemantic=function(e){var t=!1,n=[],r=0,i=null,s=0,o=0,u=0,a=0,f=0;while(s<e.length)e[s][0]==DIFF_EQUAL?(n[r++]=s,o=a,u=f,a=0,f=0,i=e[s][1]):(e[s][0]==DIFF_INSERT?a+=e[s][1].length:f+=e[s][1].length,i&&i.length<=Math.max(o,u)&&i.length<=Math.max(a,f)&&(e.splice(n[r-1],0,[DIFF_DELETE,i]),e[n[r-1]+1][0]=DIFF_INSERT,r--,r--,s=r>0?n[r-1]:-1,o=0,u=0,a=0,f=0,i=null,t=!0)),s++;t&&this.diff_cleanupMerge(e),this.diff_cleanupSemanticLossless(e),s=1;while(s<e.length){if(e[s-1][0]==DIFF_DELETE&&e[s][0]==DIFF_INSERT){var l=e[s-1][1],c=e[s][1],h=this.diff_commonOverlap_(l,c),p=this.diff_commonOverlap_(c,l);if(h>=p){if(h>=l.length/2||h>=c.length/2)e.splice(s,0,[DIFF_EQUAL,c.substring(0,h)]),e[s-1][1]=l.substring(0,l.length-h),e[s+1][1]=c.substring(h),s++}else if(p>=l.length/2||p>=c.length/2)e.splice(s,0,[DIFF_EQUAL,l.substring(0,p)]),e[s-1][0]=DIFF_INSERT,e[s-1][1]=c.substring(0,c.length-p),e[s+1][0]=DIFF_DELETE,e[s+1][1]=l.substring(p),s++;s++}s++}},diff_match_patch.prototype.diff_cleanupSemanticLossless=function(e){function t(e,t){if(!e||!t)return 6;var n=e.charAt(e.length-1),r=t.charAt(0),i=n.match(diff_match_patch.nonAlphaNumericRegex_),s=r.match(diff_match_patch.nonAlphaNumericRegex_),o=i&&n.match(diff_match_patch.whitespaceRegex_),u=s&&r.match(diff_match_patch.whitespaceRegex_),a=o&&n.match(diff_match_patch.linebreakRegex_),f=u&&r.match(diff_match_patch.linebreakRegex_),l=a&&e.match(diff_match_patch.blanklineEndRegex_),c=f&&t.match(diff_match_patch.blanklineStartRegex_);return l||c?5:a||f?4:i&&!o&&u?3:o||u?2:i||s?1:0}var n=1;while(n<e.length-1){if(e[n-1][0]==DIFF_EQUAL&&e[n+1][0]==DIFF_EQUAL){var r=e[n-1][1],i=e[n][1],s=e[n+1][1],o=this.diff_commonSuffix(r,i);if(o){var u=i.substring(i.length-o);r=r.substring(0,r.length-o),i=u+i.substring(0,i.length-o),s=u+s}var a=r,f=i,l=s,c=t(r,i)+t(i,s);while(i.charAt(0)===s.charAt(0)){r+=i.charAt(0),i=i.substring(1)+s.charAt(0),s=s.substring(1);var h=t(r,i)+t(i,s);h>=c&&(c=h,a=r,f=i,l=s)}e[n-1][1]!=a&&(a?e[n-1][1]=a:(e.splice(n-1,1),n--),e[n][1]=f,l?e[n+1][1]=l:(e.splice(n+1,1),n--))}n++}},diff_match_patch.nonAlphaNumericRegex_=/[^a-zA-Z0-9]/,diff_match_patch.whitespaceRegex_=/\s/,diff_match_patch.linebreakRegex_=/[\r\n]/,diff_match_patch.blanklineEndRegex_=/\n\r?\n$/,diff_match_patch.blanklineStartRegex_=/^\r?\n\r?\n/,diff_match_patch.prototype.diff_cleanupEfficiency=function(e){var t=!1,n=[],r=0,i=null,s=0,o=!1,u=!1,a=!1,f=!1;while(s<e.length)e[s][0]==DIFF_EQUAL?(e[s][1].length<this.Diff_EditCost&&(a||f)?(n[r++]=s,o=a,u=f,i=e[s][1]):(r=0,i=null),a=f=!1):(e[s][0]==DIFF_DELETE?f=!0:a=!0,i&&(o&&u&&a&&f||i.length<this.Diff_EditCost/2&&o+u+a+f==3)&&(e.splice(n[r-1],0,[DIFF_DELETE,i]),e[n[r-1]+1][0]=DIFF_INSERT,r--,i=null,o&&u?(a=f=!0,r=0):(r--,s=r>0?n[r-1]:-1,a=f=!1),t=!0)),s++;t&&this.diff_cleanupMerge(e)},diff_match_patch.prototype.diff_cleanupMerge=function(e){e.push([DIFF_EQUAL,""]);var t=0,n=0,r=0,i="",s="",o;while(t<e.length)switch(e[t][0]){case DIFF_INSERT:r++,s+=e[t][1],t++;break;case DIFF_DELETE:n++,i+=e[t][1],t++;break;case DIFF_EQUAL:n+r>1?(n!==0&&r!==0&&(o=this.diff_commonPrefix(s,i),o!==0&&(t-n-r>0&&e[t-n-r-1][0]==DIFF_EQUAL?e[t-n-r-1][1]+=s.substring(0,o):(e.splice(0,0,[DIFF_EQUAL,s.substring(0,o)]),t++),s=s.substring(o),i=i.substring(o)),o=this.diff_commonSuffix(s,i),o!==0&&(e[t][1]=s.substring(s.length-o)+e[t][1],s=s.substring(0,s.length-o),i=i.substring(0,i.length-o))),n===0?e.splice(t-r,n+r,[DIFF_INSERT,s]):r===0?e.splice(t-n,n+r,[DIFF_DELETE,i]):e.splice(t-n-r,n+r,[DIFF_DELETE,i],[DIFF_INSERT,s]),t=t-n-r+(n?1:0)+(r?1:0)+1):t!==0&&e[t-1][0]==DIFF_EQUAL?(e[t-1][1]+=e[t][1],e.splice(t,1)):t++,r=0,n=0,i="",s=""}e[e.length-1][1]===""&&e.pop();var u=!1;t=1;while(t<e.length-1)e[t-1][0]==DIFF_EQUAL&&e[t+1][0]==DIFF_EQUAL&&(e[t][1].substring(e[t][1].length-e[t-1][1].length)==e[t-1][1]?(e[t][1]=e[t-1][1]+e[t][1].substring(0,e[t][1].length-e[t-1][1].length),e[t+1][1]=e[t-1][1]+e[t+1][1],e.splice(t-1,1),u=!0):e[t][1].substring(0,e[t+1][1].length)==e[t+1][1]&&(e[t-1][1]+=e[t+1][1],e[t][1]=e[t][1].substring(e[t+1][1].length)+e[t+1][1],e.splice(t+1,1),u=!0)),t++;u&&this.diff_cleanupMerge(e)},diff_match_patch.prototype.diff_xIndex=function(e,t){var n=0,r=0,i=0,s=0,o;for(o=0;o<e.length;o++){e[o][0]!==DIFF_INSERT&&(n+=e[o][1].length),e[o][0]!==DIFF_DELETE&&(r+=e[o][1].length);if(n>t)break;i=n,s=r}return e.length!=o&&e[o][0]===DIFF_DELETE?s:s+(t-i)},diff_match_patch.prototype.diff_prettyHtml=function(e){var t=[],n=/&/g,r=/</g,i=/>/g,s=/\n/g;for(var o=0;o<e.length;o++){var u=e[o][0],a=e[o][1],f=a.replace(n,"&amp;").replace(r,"&lt;").replace(i,"&gt;").replace(s,"&para;<br>");switch(u){case DIFF_INSERT:t[o]='<ins style="background:#e6ffe6;">'+f+"</ins>";break;case DIFF_DELETE:t[o]='<del style="background:#ffe6e6;">'+f+"</del>";break;case DIFF_EQUAL:t[o]="<span>"+f+"</span>"}}return t.join("")},diff_match_patch.prototype.diff_text1=function(e){var t=[];for(var n=0;n<e.length;n++)e[n][0]!==DIFF_INSERT&&(t[n]=e[n][1]);return t.join("")},diff_match_patch.prototype.diff_text2=function(e){var t=[];for(var n=0;n<e.length;n++)e[n][0]!==DIFF_DELETE&&(t[n]=e[n][1]);return t.join("")},diff_match_patch.prototype.diff_levenshtein=function(e){var t=0,n=0,r=0;for(var i=0;i<e.length;i++){var s=e[i][0],o=e[i][1];switch(s){case DIFF_INSERT:n+=o.length;break;case DIFF_DELETE:r+=o.length;break;case DIFF_EQUAL:t+=Math.max(n,r),n=0,r=0}}return t+=Math.max(n,r),t},diff_match_patch.prototype.diff_toDelta=function(e){var t=[];for(var n=0;n<e.length;n++)switch(e[n][0]){case DIFF_INSERT:t[n]="+"+encodeURI(e[n][1]);break;case DIFF_DELETE:t[n]="-"+e[n][1].length;break;case DIFF_EQUAL:t[n]="="+e[n][1].length}return t.join("	").replace(/%20/g," ")},diff_match_patch.prototype.diff_fromDelta=function(e,t){var n=[],r=0,i=0,s=t.split(/\t/g);for(var o=0;o<s.length;o++){var u=s[o].substring(1);switch(s[o].charAt(0)){case"+":try{n[r++]=[DIFF_INSERT,decodeURI(u)]}catch(a){throw new Error("Illegal escape in diff_fromDelta: "+u)}break;case"-":case"=":var f=parseInt(u,10);if(isNaN(f)||f<0)throw new Error("Invalid number in diff_fromDelta: "+u);var l=e.substring(i,i+=f);s[o].charAt(0)=="="?n[r++]=[DIFF_EQUAL,l]:n[r++]=[DIFF_DELETE,l];break;default:if(s[o])throw new Error("Invalid diff operation in diff_fromDelta: "+s[o])}}if(i!=e.length)throw new Error("Delta length ("+i+") does not equal source text length ("+e.length+").");return n},diff_match_patch.prototype.match_main=function(e,t,n){if(e==null||t==null||n==null)throw new Error("Null input. (match_main)");return n=Math.max(0,Math.min(n,e.length)),e==t?0:e.length?e.substring(n,n+t.length)==t?n:this.match_bitap_(e,t,n):-1},diff_match_patch.prototype.match_bitap_=function(e,t,n){function s(e,r){var s=e/t.length,o=Math.abs(n-r);return i.Match_Distance?s+o/i.Match_Distance:o?1:s}if(t.length>this.Match_MaxBits)throw new Error("Pattern too long for this browser.");var r=this.match_alphabet_(t),i=this,o=this.Match_Threshold,u=e.indexOf(t,n);u!=-1&&(o=Math.min(s(0,u),o),u=e.lastIndexOf(t,n+t.length),u!=-1&&(o=Math.min(s(0,u),o)));var a=1<<t.length-1;u=-1;var f,l,c=t.length+e.length,h;for(var p=0;p<t.length;p++){f=0,l=c;while(f<l)s(p,n+l)<=o?f=l:c=l,l=Math.floor((c-f)/2+f);c=l;var d=Math.max(1,n-l+1),v=Math.min(n+l,e.length)+t.length,m=Array(v+2);m[v+1]=(1<<p)-1;for(var g=v;g>=d;g--){var y=r[e.charAt(g-1)];p===0?m[g]=(m[g+1]<<1|1)&y:m[g]=(m[g+1]<<1|1)&y|((h[g+1]|h[g])<<1|1)|h[g+1];if(m[g]&a){var b=s(p,g-1);if(b<=o){o=b,u=g-1;if(!(u>n))break;d=Math.max(1,2*n-u)}}}if(s(p+1,n)>o)break;h=m}return u},diff_match_patch.prototype.match_alphabet_=function(e){var t={};for(var n=0;n<e.length;n++)t[e.charAt(n)]=0;for(var n=0;n<e.length;n++)t[e.charAt(n)]|=1<<e.length-n-1;return t},diff_match_patch.prototype.patch_addContext_=function(e,t){if(t.length==0)return;var n=t.substring(e.start2,e.start2+e.length1),r=0;while(t.indexOf(n)!=t.lastIndexOf(n)&&n.length<this.Match_MaxBits-this.Patch_Margin-this.Patch_Margin)r+=this.Patch_Margin,n=t.substring(e.start2-r,e.start2+e.length1+r);r+=this.Patch_Margin;var i=t.substring(e.start2-r,e.start2);i&&e.diffs.unshift([DIFF_EQUAL,i]);var s=t.substring(e.start2+e.length1,e.start2+e.length1+r);s&&e.diffs.push([DIFF_EQUAL,s]),e.start1-=i.length,e.start2-=i.length,e.length1+=i.length+s.length,e.length2+=i.length+s.length},diff_match_patch.prototype.patch_make=function(e,t,n){var r,i;if(typeof e=="string"&&typeof t=="string"&&typeof n=="undefined")r=e,i=this.diff_main(r,t,!0),i.length>2&&(this.diff_cleanupSemantic(i),this.diff_cleanupEfficiency(i));else if(e&&typeof e=="object"&&typeof t=="undefined"&&typeof n=="undefined")i=e,r=this.diff_text1(i);else if(typeof e=="string"&&t&&typeof t=="object"&&typeof n=="undefined")r=e,i=t;else{if(typeof e!="string"||typeof t!="string"||!n||typeof n!="object")throw new Error("Unknown call format to patch_make.");r=e,i=n}if(i.length===0)return[];var s=[],o=new diff_match_patch.patch_obj,u=0,a=0,f=0,l=r,c=r;for(var h=0;h<i.length;h++){var p=i[h][0],d=i[h][1];!u&&p!==DIFF_EQUAL&&(o.start1=a,o.start2=f);switch(p){case DIFF_INSERT:o.diffs[u++]=i[h],o.length2+=d.length,c=c.substring(0,f)+d+c.substring(f);break;case DIFF_DELETE:o.length1+=d.length,o.diffs[u++]=i[h],c=c.substring(0,f)+c.substring(f+d.length);break;case DIFF_EQUAL:d.length<=2*this.Patch_Margin&&u&&i.length!=h+1?(o.diffs[u++]=i[h],o.length1+=d.length,o.length2+=d.length):d.length>=2*this.Patch_Margin&&u&&(this.patch_addContext_(o,l),s.push(o),o=new diff_match_patch.patch_obj,u=0,l=c,a=f)}p!==DIFF_INSERT&&(a+=d.length),p!==DIFF_DELETE&&(f+=d.length)}return u&&(this.patch_addContext_(o,l),s.push(o)),s},diff_match_patch.prototype.patch_deepCopy=function(e){var t=[];for(var n=0;n<e.length;n++){var r=e[n],i=new diff_match_patch.patch_obj;i.diffs=[];for(var s=0;s<r.diffs.length;s++)i.diffs[s]=r.diffs[s].slice();i.start1=r.start1,i.start2=r.start2,i.length1=r.length1,i.length2=r.length2,t[n]=i}return t},diff_match_patch.prototype.patch_apply=function(e,t){if(e.length==0)return[t,[]];e=this.patch_deepCopy(e);var n=this.patch_addPadding(e);t=n+t+n,this.patch_splitMax(e);var r=0,i=[];for(var s=0;s<e.length;s++){var o=e[s].start2+r,u=this.diff_text1(e[s].diffs),a,f=-1;if(u.length>this.Match_MaxBits){a=this.match_main(t,u.substring(0,this.Match_MaxBits),o);if(a!=-1){f=this.match_main(t,u.substring(u.length-this.Match_MaxBits),o+u.length-this.Match_MaxBits);if(f==-1||a>=f)a=-1}}else a=this.match_main(t,u,o);if(a==-1)i[s]=!1,r-=e[s].length2-e[s].length1;else{i[s]=!0,r=a-o;var l;f==-1?l=t.substring(a,a+u.length):l=t.substring(a,f+this.Match_MaxBits);if(u==l)t=t.substring(0,a)+this.diff_text2(e[s].diffs)+t.substring(a+u.length);else{var c=this.diff_main(u,l,!1);if(u.length>this.Match_MaxBits&&this.diff_levenshtein(c)/u.length>this.Patch_DeleteThreshold)i[s]=!1;else{this.diff_cleanupSemanticLossless(c);var h=0,p;for(var d=0;d<e[s].diffs.length;d++){var v=e[s].diffs[d];v[0]!==DIFF_EQUAL&&(p=this.diff_xIndex(c,h)),v[0]===DIFF_INSERT?t=t.substring(0,a+p)+v[1]+t.substring(a+p):v[0]===DIFF_DELETE&&(t=t.substring(0,a+p)+t.substring(a+this.diff_xIndex(c,h+v[1].length))),v[0]!==DIFF_DELETE&&(h+=v[1].length)}}}}}return t=t.substring(n.length,t.length-n.length),[t,i]},diff_match_patch.prototype.patch_addPadding=function(e){var t=this.Patch_Margin,n="";for(var r=1;r<=t;r++)n+=String.fromCharCode(r);for(var r=0;r<e.length;r++)e[r].start1+=t,e[r].start2+=t;var i=e[0],s=i.diffs;if(s.length==0||s[0][0]!=DIFF_EQUAL)s.unshift([DIFF_EQUAL,n]),i.start1-=t,i.start2-=t,i.length1+=t,i.length2+=t;else if(t>s[0][1].length){var o=t-s[0][1].length;s[0][1]=n.substring(s[0][1].length)+s[0][1],i.start1-=o,i.start2-=o,i.length1+=o,i.length2+=o}i=e[e.length-1],s=i.diffs;if(s.length==0||s[s.length-1][0]!=DIFF_EQUAL)s.push([DIFF_EQUAL,n]),i.length1+=t,i.length2+=t;else if(t>s[s.length-1][1].length){var o=t-s[s.length-1][1].length;s[s.length-1][1]+=n.substring(0,o),i.length1+=o,i.length2+=o}return n},diff_match_patch.prototype.patch_splitMax=function(e){var t=this.Match_MaxBits;for(var n=0;n<e.length;n++){if(e[n].length1<=t)continue;var r=e[n];e.splice(n--,1);var i=r.start1,s=r.start2,o="";while(r.diffs.length!==0){var u=new diff_match_patch.patch_obj,a=!0;u.start1=i-o.length,u.start2=s-o.length,o!==""&&(u.length1=u.length2=o.length,u.diffs.push([DIFF_EQUAL,o]));while(r.diffs.length!==0&&u.length1<t-this.Patch_Margin){var f=r.diffs[0][0],l=r.diffs[0][1];f===DIFF_INSERT?(u.length2+=l.length,s+=l.length,u.diffs.push(r.diffs.shift()),a=!1):f===DIFF_DELETE&&u.diffs.length==1&&u.diffs[0][0]==DIFF_EQUAL&&l.length>2*t?(u.length1+=l.length,i+=l.length,a=!1,u.diffs.push([f,l]),r.diffs.shift()):(l=l.substring(0,t-u.length1-this.Patch_Margin),u.length1+=l.length,i+=l.length,f===DIFF_EQUAL?(u.length2+=l.length,s+=l.length):a=!1,u.diffs.push([f,l]),l==r.diffs[0][1]?r.diffs.shift():r.diffs[0][1]=r.diffs[0][1].substring(l.length))}o=this.diff_text2(u.diffs),o=o.substring(o.length-this.Patch_Margin);var c=this.diff_text1(r.diffs).substring(0,this.Patch_Margin);c!==""&&(u.length1+=c.length,u.length2+=c.length,u.diffs.length!==0&&u.diffs[u.diffs.length-1][0]===DIFF_EQUAL?u.diffs[u.diffs.length-1][1]+=c:u.diffs.push([DIFF_EQUAL,c])),a||e.splice(++n,0,u)}}},diff_match_patch.prototype.patch_toText=function(e){var t=[];for(var n=0;n<e.length;n++)t[n]=e[n];return t.join("")},diff_match_patch.prototype.patch_fromText=function(e){var t=[];if(!e)return t;var n=e.split("\n"),r=0,i=/^@@ -(\d+),?(\d*) \+(\d+),?(\d*) @@$/;while(r<n.length){var s=n[r].match(i);if(!s)throw new Error("Invalid patch string: "+n[r]);var o=new diff_match_patch.patch_obj;t.push(o),o.start1=parseInt(s[1],10),s[2]===""?(o.start1--,o.length1=1):s[2]=="0"?o.length1=0:(o.start1--,o.length1=parseInt(s[2],10)),o.start2=parseInt(s[3],10),s[4]===""?(o.start2--,o.length2=1):s[4]=="0"?o.length2=0:(o.start2--,o.length2=parseInt(s[4],10)),r++;while(r<n.length){var u=n[r].charAt(0);try{var a=decodeURI(n[r].substring(1))}catch(f){throw new Error("Illegal escape in patch_fromText: "+a)}if(u=="-")o.diffs.push([DIFF_DELETE,a]);else if(u=="+")o.diffs.push([DIFF_INSERT,a]);else if(u==" ")o.diffs.push([DIFF_EQUAL,a]);else{if(u=="@")break;if(u!=="")throw new Error('Invalid patch mode "'+u+'" in: '+a)}r++}}return t},diff_match_patch.patch_obj=function(){this.diffs=[],this.start1=null,this.start2=null,this.length1=0,this.length2=0},diff_match_patch.patch_obj.prototype.toString=function(){var e,t;this.length1===0?e=this.start1+",0":this.length1==1?e=this.start1+1:e=this.start1+1+","+this.length1,this.length2===0?t=this.start2+",0":this.length2==1?t=this.start2+1:t=this.start2+1+","+this.length2;var n=["@@ -"+e+" +"+t+" @@\n"],r;for(var i=0;i<this.diffs.length;i++){switch(this.diffs[i][0]){case DIFF_INSERT:r="+";break;case DIFF_DELETE:r="-";break;case DIFF_EQUAL:r=" "}n[i+1]=r+encodeURI(this.diffs[i][1])+"\n"}return n.join("").replace(/%20/g," ")},this.diff_match_patch=diff_match_patch,this.DIFF_DELETE=DIFF_DELETE,this.DIFF_INSERT=DIFF_INSERT,this.DIFF_EQUAL=DIFF_EQUAL;