(function(){var e={}.hasOwnProperty,t=function(t,n){function i(){this.constructor=t}for(var r in n)e.call(n,r)&&(t[r]=n[r]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t};define(["jquery","marionette","moment","diff_match_patch"],function(e,n,r,i){var s,o;return o=function(e){return e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\n/g,"<br>")},s=function(n){function s(){return s.__super__.constructor.apply(this,arguments)}return t(s,n),s.prototype.tagName="li",s.prototype.className="article-version",s.prototype.events={"click a.toggle-expand":"onToggleExpand","click a.toggle-edit-url-version":"onToggleEditUrlVersion","submit form":"onSubmit","click button.delete":"onDelete"},s.prototype.ui={urlVersion:"fieldset.url-version",source:"input[name=source]",headline:"input[name=headline]",publishedAt:"input[name=published-at]",byline:"input[name=byline]",body:"textarea[name=body]",stance:"input[name=stance]",headlineStance:"input[name=headline-stance]",comment:"textarea[name=comment]"},s.prototype.template=_.template('<h3><a href="#" class="toggle-expand">\n  <% if (isNew) { %>\n    Insert a version manually\n  <% } else { %>\n    Fetched <time datetime="<%- createdAt %>"><%- createdAtString %></time>\n  <% } %>\n</a></h3>\n<form method="post" action="#" class="<%- isNew ? \'create\' : \'update\' %>">\n  <fieldset class="url-version <%- isNew ? \'editing\' : \'\' %>">\n    <legend>What the website says</legend>\n    <div class="read-only">\n      <article>\n        <h4 class="headline"><%- urlVersion.headline %></h4>\n        <p class="published">\n          By <span class="byline"><%- urlVersion.byline %></span>;\n          on <span class="source"><%- urlVersion.source %></span>\n        </p>\n        <div class="body"><%= urlVersion.bodyHtml %></div>\n      </article>\n      <a href="#" class="toggle-edit-url-version">Edit what the website says</a>\n    </div>\n    <div class="edit">\n      <div class="form-group">\n        <label for="version-<%- cid %>-source">Source (publication)</label>\n        <input id="version-<%- cid %>-source" name="source" class="form-control" placeholder="e.g., The New York Times" value="<%- urlVersion.source %>" required>\n      </div>\n      <div class="form-group">\n        <label for="version-<%- cid %>-headline">Headline</label>\n        <input id="version-<%- cid %>-headline" name="headline" class="form-control" placeholder="e.g., Man Bites Dog" value="<%- urlVersion.headline %>" required>\n      </div>\n      <div class="form-group">\n        <label for="version-<%- cid %>-published-at">Published/Updated date</label>\n        <input type="datetime-local" id="version-<%- cid %>-published-at" name="published-at" class="form-control" value="<%- urlVersion.publishedAt %>" required>\n        <small class="help-block">(in your timezone)</small>\n      </div>\n      <div class="form-group">\n        <label for="version-<%- cid %>-byline">Byline</label>\n        <input id="version-<%- cid %>-byline" name="byline" class="form-control" placeholder="e.g., Adam Hooper, Craig Silverman" value="<%- urlVersion.byline %>">\n      </div>\n      <div class="form-group">\n        <label for="version-<%- cid %>-body">Body</label>\n        <textarea id="version-<%- cid %>-body" name="body" class="form-control" rows="5" placeholder="e.g. Each paragraph was separated from its neighbors by two newlines." required><%- urlVersion.body %></textarea>\n      </div>\n    </div>\n  </fieldset>\n  <fieldset class="article-version">\n    <legend>What Truthmaker editors say</legend>\n    <div class="form-group">\n      <label for="version-<%- cid %>-headline-stance">Does the headline support the claim?</label>\n      <div class="radio"><label><input id="version-<%- cid %>-headline-stance" type="radio" name="headline-stance" value="" <%- headlineStance ? \'\' : \'checked\' %>> I haven\'t looked</label></div>\n      <div class="radio"><label><input type="radio" name="headline-stance" value="for" <%- headlineStance == \'for\' ? \'checked\' : \'\' %>> The headline is <em>for</em> the claim</label></div>\n      <div class="radio"><label><input type="radio" name="headline-stance" value="against" <%- headlineStance == \'against\' ? \'checked\' : \'\' %>> The headline is <em>against</em> the claim</label></div>\n      <div class="radio"><label><input type="radio" name="headline-stance" value="observing" <%- headlineStance == \'observing\' ? \'checked\' : \'\' %>> The headline is merely <em>reporting</em> the claim exists</label></div>\n      <div class="radio"><label><input type="radio" name="headline-stance" value="ignoring" <%- headlineStance == \'ignoring\' ? \'checked\' : \'\' %>> The headline <em>does not mention</em> the claim</label></div>\n    </div>\n    <div class="form-group">\n      <label for="version-<%- cid %>-stance">Does the body support the claim?</label>\n      <div class="radio"><label><input id="version-<%- cid %>-stance" type="radio" name="stance" value="" <%- stance ? \'\' : \'checked\' %>> I haven\'t looked</label></div>\n      <div class="radio"><label><input type="radio" name="stance" value="for" <%- stance == \'for\' ? \'checked\' : \'\' %>> The body is <em>for</em> the claim</label></div>\n      <div class="radio"><label><input type="radio" name="stance" value="against" <%- stance == \'against\' ? \'checked\' : \'\' %>> The body is <em>against</em> the claim</label></div>\n      <div class="radio"><label><input type="radio" name="stance" value="observing" <%- stance == \'observing\' ? \'checked\' : \'\' %>> The body is merely <em>reporting</em> the claim exists</label></div>\n      <div class="radio"><label><input type="radio" name="stance" value="ignoring" <%- stance == \'ignoring\' ? \'checked\' : \'\' %>> The body <em>does not mention</em> the claim</label></div>\n    </div>\n    <div class="form-group">\n      <label for="version-<%- cid %>-comment">Comment</label>\n      <textarea id="version-<%- cid %>-comment" name="comment" class="form-control" rows="2" placeholder="A note for other Truthmaker editors"><%- comment %></textarea>\n    </div>\n  </fieldset>\n  <button type="submit" class="btn btn-default save"><%- isNew ? "Create version" : "Save changes" %></button>\n  <% if (!isNew) { %>\n    <button type="submit" class="btn delete">Delete this version</button>\n  <% } %>\n</form>'),s.prototype.render=function(){return s.__super__.render.call(this),this.$el.toggleClass("complete",!!this.model.get("stance")&&!!this.model.get("headlineStance")),this},s.prototype.onToggleExpand=function(e){return e.preventDefault(),this.$el.toggleClass("expanded")},s.prototype.onToggleEditUrlVersion=function(e){return e.preventDefault(),this.ui.urlVersion.toggleClass("editing")},s.prototype.onSubmit=function(e){var t;return e.preventDefault(),t=this.model.isNew(),this.model.save(this.getDataFromForm(),{success:function(e){return function(){e.render();if(t)return e.model.collection.add({})}}(this)})},s.prototype.onDelete=function(e){e.preventDefault();if(window.confirm("Are you sure you want to delete this version? This cannot be undone."))return this.model.destroy()},s.prototype.getBodyHtml=function(){var t,n,r,s,u;return this.model.isNew()?"":(s=this.model.collection.indexOf(this.model),t=this.model.get("urlVersion").body,s===0?e("<div/>").text(t).html().replace(/\n/g,"<br/>"):(u=this.model.collection.at(s-1).get("urlVersion").body,r=new i,n=r.diff_main(u,t),r.diff_cleanupSemantic(n),n.map(function(e){var t,n,r;n=e[0],r=e[1],t=o(r);switch(n){case-1:return"<del>"+t+"</del>";case 1:return"<ins>"+t+"</ins>";default:return t}}).join("")))},s.prototype.serializeData=function(){var e,t,n,i;return e=this.model.toJSON(),t=r(e.urlVersion.publishedAt),{isNew:this.model.isNew(),cid:this.model.cid,urlVersion:{source:e.urlVersion.source,headline:e.urlVersion.headline,publishedAt:t.format("YYYY-MM-DDTHH:mm:ss"),byline:e.urlVersion.byline,body:e.urlVersion.body,bodyHtml:this.getBodyHtml()},stance:(n=e.stance)!=null?n:"",headlineStance:(i=e.headlineStance)!=null?i:"",comment:e.comment,createdAt:e.urlVersion.createdAt,createdAtString:r(e.urlVersion.createdAt).format("YYYY-MM-DD \\a\\t h:mm A")}},s.prototype.getDataFromForm=function(){return{urlVersion:{source:this.ui.source.val().trim(),headline:this.ui.headline.val().trim(),publishedAt:r(this.ui.publishedAt.val()).toDate(),byline:this.ui.byline.val().trim(),body:this.ui.body.val().trim()},stance:this.ui.stance.filter(":checked").val()||null,headlineStance:this.ui.headlineStance.filter(":checked").val()||null,comment:this.ui.comment.val().trim()}},s}(n.ItemView)})}).call(this);