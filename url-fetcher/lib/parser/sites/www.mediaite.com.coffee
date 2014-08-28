module.exports =
  domains: [ 'www.mediaite.com' ]
  parse: (url, $, h) ->
    source: 'Mediaite'
    headline: $('h1').text()
    byline: h.texts($('span.dateline *'))
    publishedAt: new Date($('meta[name=date]').attr('content'))
    body: h.texts($('#post-body>*'))
