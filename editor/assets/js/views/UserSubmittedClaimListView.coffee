Marionette = require('backbone.marionette')

UserSubmittedClaimItemView = require('./UserSubmittedClaimItemView')
UserSubmittedClaimEmptyView = require('./UserSubmittedClaimEmptyView')

module.exports = class UserSubmittedClaimListView extends Marionette.CollectionView
  childView: UserSubmittedClaimItemView
  emptyView: UserSubmittedClaimEmptyView
