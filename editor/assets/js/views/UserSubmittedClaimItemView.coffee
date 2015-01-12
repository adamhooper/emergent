Marionette = require('backbone.marionette')
Promise = require('bluebird')
moment = require('moment')
_ = require('lodash')

module.exports = class UserSubmittedClaimItemView extends Marionette.ItemView
  className: 'user-submitted-claim'
  template: _.template("""
    <div class="actions">
      <button class="btn btn-danger report-spam"><i class="glyphicon glyphicon-exclamation-sign"></i> Report spam</button>
      <button class="btn btn-primary archive"><i class="glyphicon glyphicon-ok-sign"></i> Archive</button>
    </div>
    <p class="claim"><strong>Claim:</strong> <%- claim %></p>
    <p class="url"><strong>URL:</strong> <a target="_blank" href="<%- url %>"><%- url %></a></p>
    <p class="created-at">Requested <%- createdAtString %></p>
  """)

  events:
    'click .archive': '_onArchive'
    'click .report-spam': '_onReportSpam'

  _onArchive: ->
    Promise.resolve(@model.save({ archived: true }, { patch: true }))
      .then(=> @model.collection.remove(@model))

  _onReportSpam: ->
    Promise.resolve(@model.save({ spam: true }, { patch: true }))
      .then(=> @model.collection.remove(@model))

  serializeData: ->
    json = @model.toJSON()
    json.createdAtString = moment(json.createdAt).format('YYYY-MM-DD \\a\\t h:mm A')
    json
