module.exports =
  domains: [ 'www.azcentral.com' ]
  parse: (url, $, h) ->
    source: 'azcentral.com'
    headline: $('h1.asset-headline').text()
    byline: h.texts($('[itemprop=author] [itemprop=name]'))
    body: h.texts($('[itemprop=articleBody]>p'))
