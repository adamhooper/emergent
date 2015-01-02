module.exports =
  domains: [ 'www.inquisitr.com' ]
  parse: (url, $, h) ->
    source: 'Inquisitr'
    byline: $('h3.author [rel=author]')
    headline: $('h1.entry-title')
    body: $('section.entry-content p')
