module.exports =
  domains: [ 'www.independent.co.uk' ]
  parse: (url, $, h) ->
    source: 'The Independent'
    headline: $('h1').text().trim()
    byline: h.texts($('div.author *'))
    body: h.texts($('#main p'))
