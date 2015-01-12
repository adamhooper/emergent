Marionette = require('backbone.marionette')

module.exports = class UserSubmittedClaimEmptyView extends Marionette.ItemView
  template: -> """
    <p class="empty">There are no un-archived user-submitted claims.</p>
  """
