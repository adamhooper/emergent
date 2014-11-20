module.exports =
  domains: [ 'www.bizjournals.com' ]
  parse: (url, $, h) ->
    source: 'San Francisco Business Times'
    headline: $('h1')
    byline: $('[rel=author]')
    body: $('.articleContent p')
