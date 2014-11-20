module.exports =
  domains: [ 'theweek.com' ]
  parse: (url, $, h) ->
    source: 'The Week'
    headline: $('#nfHeadline').text().trim()
    byline: [ $('#nfBodyText em').last().text().trim() ]
    body: h.texts($('#nfBodyText>*'))
