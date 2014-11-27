module.exports =
  version: 2
  domains: [ 'worldnewsdailyreport.com' ]
  parse: (url, $, h) ->
    source: 'World News Daily Report [satire]'
    headline: $('h2.posttitle')
    byline: $('a[rel=author]')
    body: $('.post .contentstyle p')
