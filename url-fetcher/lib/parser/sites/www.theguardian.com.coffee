module.exports =
  version: 2
  domains: [ 'www.theguardian.com' ]
  parse: (url, $, h) ->
    source: 'The Guardian'
    headline: $('div#article-header h1')
    byline: $('[itemprop=author]')
    publishedAt: new Date($('meta[property="article:modified_time"]').attr('content'))
    body: $('div#article-body-blocks p')
