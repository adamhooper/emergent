define [ 'backbone', '../models/Story' ], (Backbone, Story) ->
  class Stories extends Backbone.Collection
    url: '/story'
    model: Story
