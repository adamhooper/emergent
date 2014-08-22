module.exports =
  domains: [ 'www.glamour.com' ]
  parse: (url, $, h) ->
    source: 'Glamour'
    headline: $('h1').text()
    byline: h.texts($('.article-header cite.author *'))
    publishedAt: new Date($('head time').attr('datetime')) # weirdos
    body: h.texts($('.article-text p'))
