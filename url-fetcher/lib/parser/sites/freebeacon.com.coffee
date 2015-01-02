module.exports =
  domains: [ 'freebeacon.com' ]
  parse: (url, $, h) ->
    source: 'The Washington Free Beacon'
    byline: $('[rel=author]')
    headline: $('h2.entry-title')
    body: $('.entry-content p.p1')
