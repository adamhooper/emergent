module.exports =
  domains: [ 'www.bizjournals.com' ]
  parse: (url, $, h) ->
    source: 'San Francisco Business Times'
    headline: $('h1')
    byline: $('[rel=author]')
    publishedAt: new Date($('meta[name=date]').attr('content'))
    body: $('.articleContent p')
