module.exports =
  domains: [ 'worldnewsdailyreport.com' ]
  parse: (url, $, h) ->
    source: 'World News Daily Report'
    headline: $('h2.posttitle')
    byline: $('a[rel=author]')
    body: $('.post .contentstyle p')
