module.exports =
  domains: [ 'www.nydailynews.com' ]
  parse: (url, $, h) ->
    source: 'New York Daily News'
    headline: $('h1').text()
    byline: h.texts($('[rel=author]'))
    publishedAt: h.moment.tz($('#a-date-published').attr('content'), 'America/New_York')
    body: h.texts($('#a-subheader, article p'))
