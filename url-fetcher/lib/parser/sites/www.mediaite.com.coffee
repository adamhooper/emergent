module.exports =
  domains: [ 'www.mediaite.com' ]
  parse: (url, $, h) ->
    source: 'Mediaite'
    headline: $('h1')
    byline: $('span.dateline *')
    body: $('#post-body>*')
