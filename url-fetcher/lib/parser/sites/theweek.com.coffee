module.exports =
  domains: [ 'theweek.com' ]
  parse: (url, $, h) ->
    source: 'The Week'
    headline: $('#nfHeadline').text().trim()
    byline: [ $('#nfBodyText em').last().text().trim() ]
    publishedAt: new Date($('meta[property="article:published_time"]').attr('content') + 'Z')
    body: h.texts($('#nfBodyText>*'))
