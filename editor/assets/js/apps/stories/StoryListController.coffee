App = require('../../app')
Story = require('../../models/Story')
StoryListLayout = require('../../views/StoryListLayout')

module.exports =
  go: ->
    App.request('stories/index')
      .then (collection) ->
        layout = StoryListLayout.forCollectionInRegion(collection, App.mainRegion)

        # TODO are there leaks with `.on` calls?
        layout.on 'items:delete', (model) ->
          collection.remove(model)

          App.request('stories/destroy', model.id)
            .fail((err) -> console.log(err))

        layout.on 'new:submit', (data) ->
          model = new Story(data, isNew: true)
          collection.add(model)
          model.save()

        layout.on 'list:click', (slug) ->
          App.trigger('stories:show', slug)

        layout.on 'list:delete', (slug) ->
          model = collection.get(slug)
          model.destroy()
