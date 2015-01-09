Marionette = require('backbone.marionette')
StoryListView = require('./StoryListView')
NewStoryView = require('./NewStoryView')

module.exports = class StoryListLayout extends Marionette.LayoutView
  className: 'container story-list-layout'

  template: -> """
    <h1>Stories</h1>
    <div class="new-story-form"></div>
    <div class="explanation">
      <p>A Story is an actual event: myth, truth, or somewhere in between. Lots of news sites may write lots of articles about a single Story.</p>
      <p>Here are the stories in the system already:</p>
    </div>
    <div class="story-list"></div>
    """

  regions:
    list: '.story-list'
    newForm: '.new-story-form'

  initialize: ->
    @newForm.on 'show', (view) =>
      if view?
        @listenTo view, 'submit', (data) =>
          @trigger('new:submit', data)

    @newForm.on 'destroy', (view) =>
      @stopListening(view) if view?

    @list.on 'show', (view) =>
      if view?
        @listenTo(view, 'childview:delete', ((cv) => @trigger('list:delete', cv.model.attributes.slug)))
        @listenTo(view, 'childview:click', ((cv) => @trigger('list:click', cv.model.attributes.slug)))

    @list.on 'destroy', (view) =>
      @stopListening(view) if view?

StoryListLayout.forCollectionInRegion = (collection, region) ->
  layout = new StoryListLayout
  region.show(layout)

  list = new StoryListView
    collection: collection

  newForm = new NewStoryView

  layout.list.show(list)
  layout.newForm.show(newForm)

  layout

StoryListLayout
