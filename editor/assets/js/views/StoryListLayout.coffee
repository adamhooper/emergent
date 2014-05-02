define [
  'marionette'
  'views/StoryListView'
  'views/NewStoryView'
], (Marionette, StoryListView, NewStoryView) ->
  class StoryListLayout extends Marionette.Layout
    template: -> """
      <div class="list"></div>
      <div class="new-form"></div>
      """

    regions:
      list: '.list'
      newForm: '.new-form'

    initialize: ->
      @newForm.on 'show', (view) =>
        if view?
          @listenTo view, 'submit', (data) =>
            @trigger('new:submit', data)

      @newForm.on 'close', (view) =>
        @stopListening(view) if view?

      @list.on 'show', (view) =>
        if view?
          @listenTo view, 'delete', (slug) =>
            @trigger('list:delete', slug)

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
