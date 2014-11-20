module.exports =
  domains: [ 'www.glamour.com' ]
  parse: (url, $, h) ->
    source: 'Glamour'
    headline: $('h1').text()
    byline: h.texts($('.article-header cite.author *'))
    body: h.texts($('.article-text p'))
