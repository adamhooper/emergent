Marionette = require('backbone.marionette')
UserSubmittedClaims = require('../collections/UserSubmittedClaims')
UserSubmittedClaimListView = require('./UserSubmittedClaimListView')

module.exports = class UserSubmittedClaimListLayout extends Marionette.LayoutView
  className: 'container user-submitted-claim-list-layout'

  template: -> """
    <div class="row header">
      <div class="col-xs-12">
        <h1>User-submitted claims</h1>
        <p class="explanation">Users have requested we track the following claims:</p>
      </div>
    </div>
    <div class="row body">
      <div class="col-xs-12 user-submitted-claims">
      </div>
    </div>
  """

  regions:
    claims: '.user-submitted-claims'

UserSubmittedClaimListLayout.forCollectionInRegion = (claims, region) ->
  layout = new UserSubmittedClaimListLayout
  region.show(layout)
  layout.claims.show(new UserSubmittedClaimListView(collection: claims))
  layout
