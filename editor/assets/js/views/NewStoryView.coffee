_ = require('lodash')
Marionette = require('backbone.marionette')

module.exports = class NewStoryView extends Marionette.ItemView
  tagName: 'form'
  className: 'new-story'
  attributes:
    method: 'post'
    action: '#'

  template: _.template '''
    <legend>Add a new story</legend>
    <div class="explanation">
      <p>Have you seen a few fishy articles online? Add a Story to chronicle the telling of the news.</p>
    </div>
    <div class="form-group">
      <label for="new-story-slug">Slug (<tt>must-look-like-this</tt>)</label>
      <input name="slug" type="text" class="form-control" id="new-story-slug" placeholder="e.g. man-bites-dog">
    </div>
    <div class="form-group">
      <label for="new-story-headline">Headline</label>
      <input name="headline" type="text" class="form-control" id="new-story-headline" placeholder="e.g. Somebody did something">
    </div>
    <div class="form-group">
      <label for="new-story-description">Two-line description</label>
      <textarea name="description" rows="3" id="new-story-description" class="form-control" placeholder="e.g. A man bit a dog, then the Internet wised up."></textarea>
    </div>
    <button type="submit" class="btn btn-primary">Add Story</button>
    '''

  events:
    'submit': 'onSubmit'

  onSubmit: (e) ->
    e.preventDefault()
    data = {}
    data[x.name] = x.value for x in @$el.serializeArray()
    @trigger('submit', data)
    @reset()

  reset: ->
    @el.reset()
