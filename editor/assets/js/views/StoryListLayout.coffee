define [
  'marionette'
  'views/StoryListView'
  'views/NewStoryView'
], (Marionette, StoryListView, NewStoryView) ->
  class StoryListLayout extends Marionette.Layout
    template: -> """
      <div class="story-list-layout">
        <h1>Stories</h1>
        <div class="explanation">
          <p>A Story is an actual event: myth, truth, or somewhere in between. Lots of news sites may write lots of articles about a single Story.</p>
          <p>Here are the stories in the system already:</p>
        </div>
        <div class="story-list"></div>
        <div class="new-story-form"></div>
      </div>
      """

    regions:
      list: '.story-list'
      newForm: '.new-story-form'

    initialize: ->
      @newForm.on 'show', (view) =>
        if view?
          @listenTo view, 'submit', (data) =>
            @trigger('new:submit', data)

      @newForm.on 'close', (view) =>
        @stopListening(view) if view?

      @list.on 'show', (view) =>
        if view?
          @listenTo(view, 'delete', ((slug) => @trigger('list:delete', slug)))
          @listenTo(view, 'click', ((slug) => @trigger('list:click', slug)))

      @list.on 'close', (view) =>
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
