define [ 'underscore', 'backbone' ], (_, Backbone) ->
  getTimezoneString = ->
    d = new Date()
    h = Math.floor(Math.abs(d.getTimezoneOffset()) / 60)
    m = d.getTimezoneOffset() % 60
    neg = d.getTimezoneOffset() > 0
    pos = d.getTimezoneOffset() < 0
    gmt = d.getTimezoneOffset() == 0

    hs = "0#{h}".slice(-2)
    ms = "0#{m}".slice(-2)

    "#{neg && '-' || ''}#{pos && '+' || ''}#{gmt && 'Z' || ''}#{hs}#{hs && ':' || ''}#{ms}"

  class Article extends Backbone.Model
    defaults:
      url: ''
      source: ''
      headline: ''
      author: ''
      body: ''
      truthiness: ''
      publishedAt: ''

    parse: (json, options) ->
      json = _.extend({}, json)
      if json.publishedAt
        d = new Date(json.publishedAt) # in original timezone
        d2 = new Date(d.getTime()) # in _our_ timezone
        yyyy = "000#{d2.getFullYear()}".slice(-4)
        mm = "0#{d2.getMonth() + 1}".slice(-2)
        dd = "0#{d2.getDate()}".slice(-2)
        hh = "0#{d2.getHours()}".slice(-2)
        mins = "0#{d2.getMinutes()}".slice(-2)
        json.publishedAt = "#{yyyy}-#{mm}-#{dd}T#{hh}:#{mins}"

      super(json, options)

    toJSON: ->
      ret = super()
      if ret.publishedAt
        ret.publishedAt += getTimezoneString()
      ret
