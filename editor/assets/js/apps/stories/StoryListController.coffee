define [ 'app' ], (App) ->
  go: ->
    require [ 'models/Story', 'views/StoryListLayout' ], (Story, StoryListLayout) ->
      fetching = App.request('stories/index')
        .done (collection) ->
          layout = StoryListLayout.forCollectionInRegion(collection, App.mainRegion)

          # TODO fix leaks with `.on` calls
          layout.on 'items:delete', (model) ->
            collection.remove(model)

            App.request('stories/destroy', model.id)
              .fail((err) -> console.log(err))

          layout.on 'new:submit', (data) ->
            model = new Story(data, isNew: true)
            collection.add(model)
            model.save()

          layout.on 'list:delete', (slug) ->
            model = collection.get(slug)
            model.destroy()
