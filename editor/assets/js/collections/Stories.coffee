Backbone = require('backbone')
Story = require('../models/Story')

module.exports = class Stories extends Backbone.Collection
  url: '/stories'
  model: Story
