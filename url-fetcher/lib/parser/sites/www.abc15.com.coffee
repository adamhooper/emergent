module.exports =
  domains: [ 'www.abc15.com' ]
  parse: (url, $, h) ->
    source: 'ABC15 Arizona'
    headline: $('.layout__content h1').text()
    byline: h.texts($('address.byline'))
    body: h.texts($('.story__content__body p'))
