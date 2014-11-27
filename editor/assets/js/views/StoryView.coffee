_ = require('lodash')
moment = require('moment')
Marionette = require('backbone.marionette')

module.exports = class StoryView extends Marionette.ItemView
  template: _.template('''
    <div class="slug">
      <h3 class="slug"><%- slug %></h3>
      <a href="#" class="back"><i class="glyphicon glyphicon-arrow-left"></i> Back to all Stories</a>
    </div>
    <form method="post" action="#">
      <div class="row">
        <div class="col-md-4">
          <p class="headline not-editing"><strong>Claim:</strong> <%- headline %></p>
          <p class="description not-editing"><strong>Description:</strong> <%- description %></p>
          <p class="published not-editing">This claim is <strong><%- published ? 'public' : 'not public' %></strong></p>
          <div class="form-group editing">
            <label for="claim-headline">The claim, in tweet form:</label>
            <textarea class="form-control" id="claim-headline" rows="2" name="headline" placeholder="A man bit a dog"><%- headline %></textarea>
          </div>
          <div class="form-group editing">
            <label for="claim-description">The claim, in two sentences:</label>
            <textarea class="form-control" id="claim-description" rows="5" name="description" placeholder="Two. Sentences."><%- description %></textarea>
          </div>
          <div class="checkbox editing">
            <label>
              <input name="published" type="checkbox" <%= published ? 'checked' : '' %>> Published</input>
            </label>
          </div>
        </div>

        <div class="col-md-4">
          <p class="not-editing">
            <strong>Origin:</strong>
            <%- origin %>
            <% if (originUrl) { %>
              <a target="_blank" href="<%- originUrl %>">[link]</a>
            <% } %>
          </p>
          <div class="form-group editing">
            <label for="claim-origin">Who said this, how, when?</label>
            <p class="not-editing"><%- origin %></p>
            <textarea class="form-control" id="claim-origin" rows="5" name="origin" placeholder="Lies Inc. said so on its blog."><%- origin %></textarea>
          </div>
          <div class="form-group origin-url editing">
            <label for="claim-origin-url">If possible, link to that:</label>
            <input type="text" class="form-control" id="claim-origin-url" name="originUrl" placeholder="http://lies.com/blog" value="<%- originUrl || '' %>">
          </div>
        </div>

        <div class="col-md-4">
          <p class="not-editing">
            <strong>Truthiness:</strong>
            <% if (truthiness == 'unknown') { %>We don't know
            <% } else if (truthiness == 'true') { %>It is <em>true</em>
            <% } else if (truthiness == 'false') { %>It is <em>false</em>
            <% } %>

            <% if (truthinessDateString) { %>
              as of <%- truthinessDateString %>
            <% } %>
          </p>
          <% if (truthinessDescription || truthinessUrl) { %>
            <p class="not-editing">
              <strong>Why is it true or false?</strong>
              <% if (truthinessDescription) { %>
                <%- truthinessDescription %>
              <% } %>
              <% if (truthinessUrl) { %>
                <a target="_blank" href="<%- truthinessUrl %>">[link]</a>
              <% } %>
            </p>
          <% } %>

          <div class="form-group editing">
            <label>Is this claim true?</label>
            <div class="radio">
              <label>
                <input id="claim-truthiness" type="radio" name="truthiness" value="unknown" <%= truthiness == 'unknown' ? 'checked' : '' %>>
                We don't know
              </label>
            </div>
            <div class="radio">
              <label>
                <input type="radio" name="truthiness" value="true" <%= truthiness == 'true' ? 'checked' : '' %>>
                It is entirely true
              </label>
            </div>
            <div class="radio">
              <label>
                <input type="radio" name="truthiness" value="false" <%= truthiness == 'false' ? 'checked' : '' %>>
                It is not entirely true
              </label>
            </div>
          </div>
          <div class="form-group truthiness-date editing">
            <label for="claim-truthiness-date">When did the world first learn whether the claim is true or false?</label>
            <input type="datetime-local" class="form-control" id="claim-truthiness-date" name="truthinessDate" value="<%- truthinessDateLocal %>">
          </div>
          <div class="form-group truthiness-description editing">
            <label for="claim-truthiness-description">Why:</label>
            <textarea class="form-control" id="claim-truthiness-description" rows="5" name="truthinessDescription" placeholder="A gnome told me."><%- truthinessDescription %></textarea>
          </div>
          <div class="form-group truthiness-url editing">
            <label for="claim-truthiness-url">Which URL broke the truth?</label>
            <input class="form-control" id="claim-truthiness-url" name="truthinessUrl" value="<%- truthinessUrl %>">
          </div>
        </div>
      </div>
      <div class="buttons editing">
        <button type="reset" class="btn btn-default reset">Cancel editing</button>
        <button type="submit" class="btn btn-primary submit">Save changes</button>
      </div>
      <div class="not-editing">
        <a href="#" class="edit">Edit this claim</a>
      </div>
    </form>
  ''')

  events:
    'click a.back': 'onBack'
    'click a.edit': 'onEdit'
    'change [name=origin]': 'showApplicableFields'
    'input [name=origin]': 'showApplicableFields' # so tabbing from origin to originUrl works
    'change [name=truthiness]': 'showApplicableFields'
    'reset form': 'onReset'
    'submit form': 'onSubmit'

  ui:
    form: 'form'
    headline: '[name=headline]'
    description: '[name=description]'
    origin: '[name=origin]'
    originUrl: '[name=originUrl]'
    originUrlWrapper: '.origin-url'
    published: '[name=published]'
    truthiness: '[name=truthiness]'
    truthinessDate: '[name=truthinessDate]'
    truthinessDescription: '[name=truthinessDescription]'
    truthinessUrl: '[name=truthinessUrl]'
    truthinessDateWrapper: '.truthiness-date'
    truthinessDescriptionWrapper: '.truthiness-description'
    truthinessUrlWrapper: '.truthiness-url'

  showApplicableFields: ->
    originNotApplicable = !@ui.origin.val()
    truthinessNotApplicable = @_getTruthiness() == 'unknown'
    @ui.originUrlWrapper.toggleClass('not-applicable', originNotApplicable)
    @ui.truthinessDateWrapper.toggleClass('not-applicable', truthinessNotApplicable)
    @ui.truthinessDescriptionWrapper.toggleClass('not-applicable', truthinessNotApplicable)
    @ui.truthinessUrlWrapper.toggleClass('not-applicable', truthinessNotApplicable)

  _getTruthiness: -> @ui.truthiness.filter(':checked').val() || 'unknown'

  _getTruthinessDate: ->
    if @_getTruthiness() != 'unknown' && (val = @ui.truthinessDate.val())
      moment(val).toDate()
    else
      null

  _getTruthinessDescription: -> @_getTruthiness() != 'unknown' && @ui.truthinessDescription.val() || ''

  _getTruthinessUrl: -> @_getTruthiness() != 'unknown' && @ui.truthinessUrl.val() || null

  onBack: (e) ->
    e.preventDefault()
    @trigger('back')

  onEdit: (e) ->
    e.preventDefault()
    @ui.form.addClass('editing')

  onReset: ->
    # Don't preventDefault()
    @ui.form.removeClass('editing')

  onSubmit: (e) ->
    e.preventDefault()

    attributes =
      headline: @ui.headline.val()
      description: @ui.description.val()
      origin: @ui.origin.val()
      originUrl: @ui.origin.val() && @ui.originUrl.val() || null
      published: @ui.published.prop('checked')
      truthiness: @_getTruthiness()
      truthinessDate: @_getTruthinessDate()
      truthinessDescription: @_getTruthinessDescription()
      truthinessUrl: @_getTruthinessUrl()

    @model.save(attributes, {
      success: => @render()
    })

  render: ->
    super()
    @showApplicableFields()

  serializeData: ->
    ret = @model.toJSON()

    if (d = ret.truthinessDate)
      ret.truthinessDateLocal = moment(d).format('YYYY-MM-DDTHH:mm:ss')
      ret.truthinessDateString = moment(d).format('YYYY-MM-DD h:mma')
    else
      ret.truthinessDateLocal = ''
      ret.truthinessDateString = ''

    ret
