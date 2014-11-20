module.exports =
  version: 2
  domains: [ 'www.ibtimes.com' ]
  parse: (url, $, h) ->
    source: 'International Business Times US'
    headline: $('h1')
    byline: $('[rel=author]')
    body: $('.article-content p')
