Marionette = require('backbone.marionette')

module.exports = class StoryListNoItemView extends Marionette.ItemView
  tagName: 'li'
  className: 'empty'
  template: -> 'We have no stories'
