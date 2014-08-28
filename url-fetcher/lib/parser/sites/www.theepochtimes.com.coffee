module.exports =
  domains: [ 'www.theepochtimes.com' ]
  parse: (url, $, h) ->
    source: 'The Epoch Times'
    headline: $('h1')
    byline: $('[rel=author]')
    publishedAt: h.moment.tz($('meta[name=date]').attr('content'), 'MMMM D, YYYY hh:mm A', 'America/New_York')
    body: $('#artcontent p')
