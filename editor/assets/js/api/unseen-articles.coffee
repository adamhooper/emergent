Backbone = require('backbone')
Promise = require('bluebird')

Articles = require('../collections/Articles')
Stories = require('../collections/Stories')

module.exports =
  installToReqres: (reqres) ->
    API =
      'unseen-articles': ->
        Promise.resolve(Backbone.$.get('/unseen-articles'))
          .then (stories) ->
            ret = new Stories(stories)
            for model in ret.models
              model.articles = new Articles(model.attributes.articles)
            ret

    for key, cb of API when !reqres.hasHandler(key)
      reqres.setHandler(key, cb)
