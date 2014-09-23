(function(){var e={}.hasOwnProperty,t=function(t,n){function i(){this.constructor=t}for(var r in n)e.call(n,r)&&(t[r]=n[r]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t};define(["underscore","moment","marionette"],function(e,n,r){var i;return i=function(r){function i(){return i.__super__.constructor.apply(this,arguments)}return t(i,r),i.prototype.template=e.template('<div class="slug">\n  <h3 class="slug"><%- slug %></h3>\n  <a href="#" class="back"><i class="glyphicon glyphicon-arrow-left"></i> Back to all Stories</a>\n</div>\n<form method="post" action="#">\n  <div class="row">\n    <div class="col-md-4">\n      <p class="headline not-editing"><strong>Claim:</strong> <%- headline %></p>\n      <p class="description not-editing"><strong>Description:</strong> <%- description %></p>\n      <div class="form-group editing">\n        <label for="claim-headline">The claim, in tweet form:</label>\n        <textarea class="form-control" id="claim-headline" rows="2" name="headline" placeholder="A man bit a dog"><%- headline %></textarea>\n      </div>\n      <div class="form-group editing">\n        <label for="claim-description">The claim, in two sentences:</label>\n        <textarea class="form-control" id="claim-description" rows="5" name="description" placeholder="Two. Sentences."><%- description %></textarea>\n      </div>\n    </div>\n\n    <div class="col-md-4">\n      <p class="not-editing">\n        <strong>Origin:</strong>\n        <%- origin %>\n        <% if (originUrl) { %>\n          <a target="_blank" href="<%- originUrl %>">[link]</a>\n        <% } %>\n      </p>\n      <div class="form-group editing">\n        <label for="claim-origin">Who said this, how, when?</label>\n        <p class="not-editing"><%- origin %></p>\n        <textarea class="form-control" id="claim-origin" rows="5" name="origin" placeholder="Lies Inc. said so on its blog."><%- origin %></textarea>\n      </div>\n      <div class="form-group origin-url editing">\n        <label for="claim-origin-url">If possible, link to that:</label>\n        <input type="text" class="form-control" id="claim-origin-url" name="originUrl" placeholder="http://lies.com/blog" value="<%- originUrl || \'\' %>">\n      </div>\n    </div>\n\n    <div class="col-md-4">\n      <p class="not-editing">\n        <strong>Truthiness:</strong>\n        <% if (truthiness == \'unknown\') { %>We don\'t know\n        <% } else if (truthiness == \'true\') { %>It is <em>true</em>\n        <% } else if (truthiness == \'false\') { %>It is <em>false</em>\n        <% } %>\n\n        <% if (truthinessDateString) { %>\n          as of <%- truthinessDateString %>\n        <% } %>\n      </p>\n      <% if (truthinessDescription || truthinessUrl) { %>\n        <p class="not-editing">\n          <strong>Why:</strong>\n          <% if (truthinessDescription) { %>\n            <%- truthinessDescription %>\n          <% } %>\n          <% if (truthinessUrl) { %>\n            <a target="_blank" href="<%- truthinessUrl %>">[link]</a>\n          <% } %>\n        </p>\n      <% } %>\n\n      <div class="form-group editing">\n        <label>Is this claim true?</label>\n        <div class="radio">\n          <label>\n            <input id="claim-truthiness" type="radio" name="truthiness" value="unknown" <%= truthiness == \'unknown\' ? \'checked\' : \'\' %>>\n            We don\'t know\n          </label>\n        </div>\n        <div class="radio">\n          <label>\n            <input type="radio" name="truthiness" value="true" <%= truthiness == \'true\' ? \'checked\' : \'\' %>>\n            It is entirely true\n          </label>\n        </div>\n        <div class="radio">\n          <label>\n            <input type="radio" name="truthiness" value="false" <%= truthiness == \'false\' ? \'checked\' : \'\' %>>\n            It is not entirely true\n          </label>\n        </div>\n      </div>\n      <div class="form-group truthiness-date editing">\n        <label for="claim-truthiness-date">When did the world first learn whether the claim is true or false?</label>\n        <input type="datetime-local" class="form-control" id="claim-truthiness-date" name="truthinessDate" value="<%- truthinessDateLocal %>">\n      </div>\n      <div class="form-group truthiness-description editing">\n        <label for="claim-truthiness-description">Why, in tweet form?</label>\n        <input class="form-control" id="claim-truthiness-description" name="truthinessDescription" value="<%- truthinessDescription %>">\n      </div>\n      <div class="form-group truthiness-url editing">\n        <label for="claim-truthiness-url">Which URL broke the truth?</label>\n        <input class="form-control" id="claim-truthiness-url" name="truthinessUrl" value="<%- truthinessUrl %>">\n      </div>\n    </div>\n  </div>\n  <div class="buttons editing">\n    <button type="reset" class="btn btn-default reset">Cancel editing</button>\n    <button type="submit" class="btn btn-primary submit">Save changes</button>\n  </div>\n  <div class="not-editing">\n    <a href="#" class="edit">Edit this claim</a>\n  </div>\n</form>'),i.prototype.events={"click a.back":"onBack","click a.edit":"onEdit","change [name=origin]":"showApplicableFields","input [name=origin]":"showApplicableFields","change [name=truthiness]":"showApplicableFields","reset form":"onReset","submit form":"onSubmit"},i.prototype.ui={form:"form",headline:"[name=headline]",description:"[name=description]",origin:"[name=origin]",originUrl:"[name=originUrl]",originUrlWrapper:".origin-url",truthiness:"[name=truthiness]",truthinessDate:"[name=truthinessDate]",truthinessDescription:"[name=truthinessDescription]",truthinessUrl:"[name=truthinessUrl]",truthinessDateWrapper:".truthiness-date",truthinessDescriptionWrapper:".truthiness-description",truthinessUrlWrapper:".truthiness-url"},i.prototype.showApplicableFields=function(){var e,t;return e=!this.ui.origin.val(),t=this._getTruthiness()==="unknown",this.ui.originUrlWrapper.toggleClass("not-applicable",e),this.ui.truthinessDateWrapper.toggleClass("not-applicable",t),this.ui.truthinessDescriptionWrapper.toggleClass("not-applicable",t),this.ui.truthinessUrlWrapper.toggleClass("not-applicable",t)},i.prototype._getTruthiness=function(){return this.ui.truthiness.filter(":checked").val()||"unknown"},i.prototype._getTruthinessDate=function(){var e;return this._getTruthiness()!=="unknown"&&(e=this.ui.truthinessDate.val())?n(e).toDate():null},i.prototype._getTruthinessDescription=function(){return this._getTruthiness()!=="unknown"&&this.ui.truthinessDescription.val()||""},i.prototype._getTruthinessUrl=function(){return this._getTruthiness()!=="unknown"&&this.ui.truthinessUrl.val()||null},i.prototype.onBack=function(e){return e.preventDefault(),this.trigger("back")},i.prototype.onEdit=function(e){return e.preventDefault(),this.ui.form.addClass("editing")},i.prototype.onReset=function(){return this.ui.form.removeClass("editing")},i.prototype.onSubmit=function(e){var t;return e.preventDefault(),t={headline:this.ui.headline.val(),description:this.ui.description.val(),origin:this.ui.origin.val(),originUrl:this.ui.origin.val()&&this.ui.originUrl.val()||null,truthiness:this._getTruthiness(),truthinessDate:this._getTruthinessDate(),truthinessDescription:this._getTruthinessDescription(),truthinessUrl:this._getTruthinessUrl()},this.model.save(t,{success:function(e){return function(){return e.render()}}(this)})},i.prototype.render=function(){return i.__super__.render.call(this),this.showApplicableFields()},i.prototype.serializeData=function(){var e,t;return t=this.model.toJSON(),(e=t.truthinessDate)?(t.truthinessDateLocal=n(e).format("YYYY-MM-DDTHH:mm:ss"),t.truthinessDateString=n(e).format("YYYY-MM-DD h:mma")):(t.truthinessDateLocal="",t.truthinessDateString=""),t},i}(r.ItemView)})}).call(this);