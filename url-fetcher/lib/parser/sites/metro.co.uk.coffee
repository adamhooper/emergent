module.exports =
  domains: [ 'metro.co.uk' ]
  parse: (url, $, h) ->
    source: 'Metro UK'
    headline: $('h1[itemprop=headline]')
    byline: $('.byline[itemprop=author]')
    body: $('article p')
