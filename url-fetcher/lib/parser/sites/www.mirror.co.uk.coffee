module.exports =
  version: 2
  domains: [ 'www.mirror.co.uk' ]
  parse: (url, $, h) ->
    source: 'mirror.co.uk'
    headline: $('h1').text().trim()
    byline: h.texts($('[rel=author]'))
    publishedAt: new Date($('meta[property="article:modified_time"]').attr('content'))
    body: h.texts($('.lead-text, .body>*'))
