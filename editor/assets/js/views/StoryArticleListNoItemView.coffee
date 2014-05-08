define [ 'underscore', 'marionette' ], (_, Marionette) ->
  class StoryArticleListNoItemView extends Marionette.ItemView
    tagName: 'li'
    className: 'no-article'

    template: _.template('''
      <p>You have not added any articles to this story yet.</p>
    ''')
