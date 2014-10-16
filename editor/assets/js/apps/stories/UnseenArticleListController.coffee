App = require('../../app')
UnseenArticleListLayout = require('../../views/UnseenArticleListLayout')

module.exports =
  go: ->
    App.request('unseen-articles')
      .then (collection) ->
        layout = UnseenArticleListLayout.forCollectionInRegion(collection, App.mainRegion)
