define [
  'marionette'
], (Marionette) ->
  class ArticleVersionListPlaceholderView extends Marionette.ItemView
    template: -> '''
      <p class="help">Click an article on the left to enter information about it here.</p>
    '''
