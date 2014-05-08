define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class NewStoryView extends Marionette.ItemView
    tagName: 'form'
    className: 'new-story'
    attributes:
      method: 'post'
      action: '#'

    template: _.template '''
      <div class="form-group">
        <label for="new-story-slug">Slug</label>
        <input name="slug" type="text" class="form-control" id="new-story-slug" placeholder="must-look-like-this">
      </div>
      <div class="form-group">
        <label for="new-story-headline">Headline</label>
        <input name="headline" type="text" class="form-control" id="new-story-headline" placeholder="Somebody did something">
      </div>
      <div class="form-group">
        <label for="new-story-description">Two-line description</label>
        <textarea name="description" rows="3" cols="30" id="new-story-description" placeholder="A brief summary"></textarea>
      </div>
      <button type="submit" class="btn btn-default">Create Story</button>
      '''

    events:
      'submit': 'onSubmit'

    onSubmit: (e) ->
      e.preventDefault()
      data = {}
      data[x.name] = x.value for x in @$el.serializeArray()
      @trigger('submit', data)

    reset: ->
      @el.reset()
