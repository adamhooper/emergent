StoryListNoItemView = require('../../assets/js/views/StoryListNoItemView')

describe 'views/StoryListNoItemView', ->
  it 'should be an li', ->
    view = new StoryListNoItemView()
    expect(view.$el).to.be('li')
