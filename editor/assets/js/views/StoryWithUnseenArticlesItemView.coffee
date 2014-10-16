_ = require('lodash')
Marionette = require('backbone.marionette')

StoryArticleListItemView = require('./StoryArticleListItemView')

module.exports = class StoryWithUnseenArticlesItemView extends Marionette.CompositeView
  tagName: 'li'
  className: 'story'
  childView: StoryArticleListItemView
  childViewContainer: '.articles'

  template: _.template('''
    <h3><%- slug %></h3>
    <ul class="articles"></ul>
  ''')

  initialize: ->
    @collection = @model.articles
    @on('childview:click', @onClick)
    
  onClick: (view, article) ->
    @trigger('focus', article) # will unfocus everything
    view.$el.addClass('focus')
