module.exports =
  domains: [ 'www.thedailybeast.com' ]
  parse: (url, $, h) ->
    source: 'The Daily Beast'
    headline: $('h1[itemprop=name]')
    byline: ''
    body: $('section.content-body p')
